//
//  ESResponse+JSONRepresentable.swift
//  Elasticsearch
//
//  Created by David Monagle on 23/7/17.
//

import Foundation
import JSON

// Adds a convenience accessor to JSONRepresentable
protocol JSONAccessor {
    func makeJSON() throws -> JSON
    var json : JSON? { get }
}

extension JSONAccessor {
    /// Returns a json object if the response can be converted to JSON otherwise returns nil
    public var json : JSON? {
        return try? makeJSON()
    }
}

extension ESResponse : JSONRepresentable, JSONAccessor {
    public func makeJSON() throws -> JSON {
        guard case let .ok(_, body) = self, let responseBody = body else { return nil }
        return try responseBody.makeJSON()
    }
    
    /// Runs the delegate function on each hit found
    public func eachHit(delegate: (JSON) -> ()) {
        guard case let .ok(_, body) = self, let responseBody = body else { return }
        responseBody.eachHit(delegate: delegate)
    }
}

extension ESResponseBody : JSONRepresentable, JSONAccessor {
    public func makeJSON() throws -> JSON {
        return try JSON(bytes: data)
    }
    
    /// Runs the delegate function on each hit found
    public func eachHit(delegate: (JSON) -> ()) {
        guard let hits = self.json?["hits"]?["hits"] else { return }
        guard let array = hits.array else { return }
        for hit in array { delegate(hit) }
    }
}

