//
//  ESResponse+JSONRepresentable.swift
//  Elasticsearch
//
//  Created by David Monagle on 23/7/17.
//

import Foundation
import JSON

extension ESResponseBody : JSONRepresentable {
    public func makeJSON() throws -> JSON {
        return try JSON(bytes: data)
    }
    
    /// Returns a json object if the response can be converted to JSON otherwise returns nil
    public var json : JSON? {
        return try? makeJSON()
    }

    /// Runs the delegate function on each hit found
    public func eachHit(delegate: (JSON) -> ()) {
        guard let hits = self.json?["hits"]?["hits"] else { return }
        guard let array = hits.array else { return }
        for hit in array { delegate(hit) }
    }
}

