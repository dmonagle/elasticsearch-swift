//
//  ESReponse.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 21/7/17.
//
//

import Foundation

public enum ESResponse {
    case ok(HTTPURLResponse, ESResponseBody?)
    case error(ESError)

    public var success: Bool {
        if case .ok = self {
            return true
        }
        return false
    }
}

public struct ESResponseBody : CustomStringConvertible {
    public var data : Data
    
    public init(data: Data) { self.data = data }
    
    public func toDict() -> Dictionary<String, Any>? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return json
        }
        else {
            return nil
        }
    }
    
    public var description: String {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

