public protocol ESContext {
}

public protocol ESIndexable : ESIndexNameable {
    static var esIndex : ESIndex { get }
    static var esType : String { get }
    
    var esIndex : ESIndex { get }
    var esType : String { get }
    var esId: String { get }
    var esParentId: String? { get }
    
    func serializeES(in: ESContext?) throws -> JSONStringRepresentable
}

extension ESIndexable {
    public func serializeES() throws -> JSONStringRepresentable {
        return try serializeES(in: nil)
    }
    
    public var esParentId: String? { get { return nil } }
    
    public var esIndex : ESIndex {
        return Self.esIndex
    }
    
    public var esType : String  {
        return Self.esType
    }
}
