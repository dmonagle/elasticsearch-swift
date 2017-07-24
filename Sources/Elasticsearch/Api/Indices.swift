import Foundation

public extension ESClient {
    public func createIndex(name: ESIndexNameable, body: JSONStringRepresentable? = nil) throws -> ESResponse {
        let path = esPathify(prefixIndex(name))
        
        return request(method: RequestMethod.PUT, path: path, requestBody: body ?? nil)
    }
    
    public func deleteIndex(name: ESIndexNameable) throws -> ESResponse {
        let path = esPathify(prefixIndex(name))
        
        return request(method: RequestMethod.DELETE, path: path)
    }
    
    public func indexExists(name: ESIndexNameable) -> Bool {
        let path = esPathify(prefixIndex(name))
        
        let requestResult = request(method: RequestMethod.HEAD, path: path)
        
        switch requestResult {
        case .ok(let httpResponse, _):
            return httpResponse.statusCode == 200
        default:
            return false
        }
    }
    
    public func ensureIndex(name: ESIndexNameable, body: JSONStringRepresentable) throws {
        if (!indexExists(name: name)) {
            _ = try createIndex(name: name, body: body)
        }
    }
    
    public func ensureIndex(name: ESIndexNameable, fromFile file: String) throws {
        guard FileManager.default.fileExists(atPath: file) else { throw ESError.indexFileNotFound(file) }
        let body = try String(contentsOfFile: file)
        try ensureIndex(name: name, body: body)
    }
}
