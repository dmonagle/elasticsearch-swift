//
//  Parameter.swift
//  Elasticsearch
//
//  Created by David Monagle on 22/11/16.
//
//  Extensions to the Dictionary type to allow manipulation of Elasticsearch parameters

import Foundation
import Node

/// Common ES parameters
/// parameters like index, type and id are not included  as they are normally passed in the path of the request
let ES_COMMON_PARAMETERS = [
    "ignore",
    "index",
    "type",
    "id",
    "body",
    "node_id",
    "name",
    "field"
]

/// Common ES parameters used in queries
let ES_COMMON_QUERY_PARAMETERS = [
    "format",
    "pretty",
    "human"
]

public protocol ESParamRepresentable {
    func makeESParam() -> ESParam
    func esListify() -> ESParamRepresentable
    func esPathify() -> ESParamRepresentable
}

internal struct ESCharacters {
    static let PathStripCharacters : CharacterSet = _PathStripCharacters
    
    private static var _PathStripCharacters : CharacterSet {
        get {
            var chars = CharacterSet.whitespacesAndNewlines
            chars.insert("/")
            return chars
        }
    }
}

extension ESParamRepresentable {
    // Escapes the string representation
    public func elasticsearchEscape() -> ESParamRepresentable {
        return self.makeESParam().string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    public func esListify() -> ESParamRepresentable {
        let param = self.makeESParam()
        if let array : [ESParamRepresentable] = param.array {
            return array.esListify()
        }
        else {
            return elasticsearchEscape()
        }
    }
    
    public func esPathify() -> ESParamRepresentable {
        let param = self.makeESParam()
        if let array : [ESParamRepresentable] = param.array {
            return array.esListify()
        }
        else if let string = param.string {
            return string.trimmingCharacters(in: ESCharacters.PathStripCharacters).elasticsearchEscape()
        }
        return self
    }
}

// MARK: - ESParams

public typealias ESParams = Dictionary<String, ESParam>

extension Dictionary where Key == String, Value == ESParam {
    func queryString() -> String {
        var components: [String] = []
        
        for (key, value) in self {
            if let encodedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
                let encodedValue = value.makeESParam().string?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                components.append("\(encodedKey)=\(encodedValue)")
            }
        }
        
        return components.joined(separator: "&")
    }
}

extension Array where Element == ESParamRepresentable {
    func esListify() -> String {
        let reducedList : [String] = self.map { $0.esListify().makeESParam().string }.filter { $0 != nil }.map { $0! }
        return
            reducedList
                .filter { !$0.isEmpty }
                .joined(separator: ",")
    }
    
    func esPathify() -> String {
        let reducedPath : [String] = self.map { $0.esPathify().makeESParam().string }.filter { $0 != nil }.map { $0! }
        return
            reducedPath
                .filter { !$0.isEmpty }
                .joined(separator: "/")
    }
}

// MARK: - ESParam

/// ESParam
public final class ESParam : StructuredDataWrapper {
    public static let defaultContext = emptyContext
    
    public var wrapped: StructuredData
    public var context: Context
    
    public init(_ wrapped: StructuredData, in context: Context?) {
        self.wrapped = wrapped
        self.context = context ?? emptyContext
    }
}

extension ESParam : ESParamRepresentable {
    public func makeESParam() -> ESParam {
        return self
    }
}

extension String : ESParamRepresentable {
    public func makeESParam() -> ESParam {
        return ESParam(self)
    }
}

extension Dictionary where Key == String, Value == ESParam {
    public func enforce(_ path: String) throws -> ESParam {
        guard let result = self[path] else { throw ESError.emptyRequiredParameter(path) }
        return result
    }
    
    public func get(_ path: String, default defaultValue: String) throws -> ESParam {
        guard let value = self[path] else { return ESParam(defaultValue) }
        return value
    }
    
    /// Sets a key to the given value if it's not already set
    public mutating func setDefault(for key: Key, to value: String) {
        if (self[key] == nil) { self[key] = ESParam(value) }
    }
}

public func esPathify(_ path: ESParamRepresentable? ...) -> String {
    return path.filter { $0 != nil }.map { $0! }.esPathify()
}

public func esListify(_ path: ESParamRepresentable? ...) -> String {
    return path.filter { $0 != nil }.map { $0! }.esListify()
}
