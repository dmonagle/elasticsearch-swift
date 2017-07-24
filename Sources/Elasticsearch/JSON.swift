//
//  JSON.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 21/7/17.
//
//

import Foundation
import JSON

public protocol JSONStringRepresentable {
    func JSONString(pretty: Bool) -> String?
}

extension JSONStringRepresentable {
    public func JSONString() -> String? {
        return JSONString(pretty: false)
    }
}

extension String : JSONStringRepresentable {
    public func JSONString(pretty: Bool) -> String? {
        return self
    }
}

extension Dictionary: JSONStringRepresentable {
    public func JSONString(pretty: Bool) -> String? {
        guard Key.self is String.Type else { return nil }
        let options = pretty ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions.init(rawValue: 0)
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension JSON : JSONStringRepresentable {
    public func JSONString(pretty: Bool) -> String? {
        guard let bytes = try? self.serialize(prettyPrint: pretty) else { return nil }
        guard let string = String(bytes: bytes, encoding: .utf8) else { return nil }
        return string
    }
}
