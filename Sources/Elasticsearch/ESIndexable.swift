public protocol ESContext {
}

public protocol ESIndexable : ESIndexNameable {
    static var esIndex : ESIndex { get }
    func serializeES(in: ESContext?) throws -> JSONStringable
}

extension ESIndexable {
    public func serializeES() throws -> JSONStringable {
        return try serializeES(in: nil)
    }
    
    public var esIndex : ESIndex {
        return Self.esIndex
    }
}
