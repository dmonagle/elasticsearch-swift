import Foundation

public class ESBulkProxy {
    static let defaultThreshold = 12_000_000
    private var client : ESClient
    public var threshhold: Int = defaultThreshold
    public private(set) var totalRecords: Int
    public private(set) var recordsInBuffer: Int
    
    private let NewLine: UInt8 = 0x0A
    private var buffer : [UInt8]
    
    public init(client: ESClient, threshold: Int? = nil) {
        self.client = client
        if let threshold = threshold { self.threshhold = threshold }
        totalRecords = 0
        buffer = []
        buffer.reserveCapacity(threshhold)
        recordsInBuffer = 0
    }
    
    deinit {
        try? flush()
    }
    
    private func resetBuffer() {
        buffer = []
        recordsInBuffer = 0
    }
    
    private func ensureBufferEndsWithNewline() {
        if buffer.last != NewLine { buffer.append(NewLine)}
    }
    public func flush() throws {
        guard !buffer.isEmpty else { return }
        ensureBufferEndsWithNewline()
        client.logger?.log(.debug, message: "Flushing Elasticsearch bulk proxy: \(recordsInBuffer), \(buffer.count) bytes.")
        let data = Data(bytes: buffer)
        let _ = try client.bulk(body: data)
        resetBuffer()
    }
    
    public func append(input: String) throws {
        try append(bytes: input.bytes)
    }
    
    internal func append(bytes: [UInt8]) throws {
        if bytes.count > threshhold { threshhold = bytes.count } // If a single input doesn't fit within the threshold, expand the threshold to allow it
        if bytes.count > (threshhold - buffer.count) { try flush() } // Flush the buffer if the input doesn't fit
        buffer += bytes
        recordsInBuffer += 1
        totalRecords += 1
    }
    
    public func append(action: ESBulkAction, index: ESIndexNameable, type: String, id: String, data: JSONStringRepresentable?) throws {
        guard let prefixedIndex = client.prefixIndex(index).string else { throw ESError.missingIndexName }
        var actionBytes = "{\"\(action.rawValue)\":{\"_index\":\"\(prefixedIndex)\",\"_type\":\"\(type)\",\"_id\":\"\(id)\"}}\n".bytes
        if let jsonBytes = data?.JSONString()?.bytes {
            actionBytes += jsonBytes
            if actionBytes.last != NewLine { actionBytes.append(NewLine)}
        }
        try append(bytes: actionBytes)
    }
    
    public func append(action: ESBulkAction = .index, indexable: ESIndexable, in context: ESContext? = nil) throws {
        let indexableType = type(of: indexable)
        let data : JSONStringRepresentable?
        
        switch action {
        case .delete:
            data = nil
        default:
            data = try indexable.serializeES(in: context)
        }
        try self.append(action: action, index: indexableType.esIndex, type: indexableType.esType, id: indexable.esId, data: data)
    }
}
