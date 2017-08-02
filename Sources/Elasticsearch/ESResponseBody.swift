//
//  ESResponseBody.swift
//  Elasticsearch
//
//  Created by David Monagle on 1/8/17.
//
//

import Foundation

public struct ESResponseBody : CustomStringConvertible {
    public var data : Data
    
    public init(data: Data) { self.data = data }
    
    public func toDictionary() -> Dictionary<String, Any>? {
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

extension ESResponseBody {
    /// Returns a dictionary object of the hits. If hits doesn't exist, returns an empty dictionary
    func extractHitsDictionary() -> [String: Any] {
        guard let dict = toDictionary() else { return [:] }
        guard let hits = dict["hits"] as? [String: Any] else { return [:] }
        return hits
    }
    
    /// Returns an array of dictionaries containing the hits. Return an empty array if hits doesn't exist
    func extractHitsDataDictionary() -> [[String: Any]] {
        guard let hitsData = extractHitsDictionary()["hits"] as? [[String: Any]] else { return [] }
        return hitsData
    }
    
    /// Returns an array of dictionaries containing the hit sources. Return an empty array if hits doesn't exist
    func extractSourcesDictionary() -> [[String: Any]] {
        return extractHitsDataDictionary().map { $0["_source"] as? [String: Any] }.filter { $0 != nil }.map { $0! }
    }
}

