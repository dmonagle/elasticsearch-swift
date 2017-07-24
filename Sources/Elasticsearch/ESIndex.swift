public protocol ESIndexNameable {
    var esIndex : ESIndex { get }
}

public struct ESIndex : ESIndexNameable {
    public var prefix : String?
    public var name : String
    
    public init(prefix: String? = nil, _ name: String) {
        self.prefix = prefix
        self.name = name
    }
    
    public var esIndex : ESIndex { get { return self } }
}

extension String : ESIndexNameable {
    public var esIndex : ESIndex {
        return ESIndex(self)
    }
}

extension ESParam : ESIndexNameable {
    public var esIndex: ESIndex {
        return ESIndex(self.string ?? "")
    }
}
