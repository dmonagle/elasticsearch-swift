//
//  Bulk.swift
//  Elasticsearch
//
//  Created by David Monagle on 23/7/17.
//

import Foundation
import JSON

public enum ESBulkAction: String {
    case index /// Will add or replace a document as necessary
    case create /// Will fail if a document with the same index and type exists already
    case delete /// Does not expect a source on the following line, and has the same semantics as the standard delete API
    case update /// Expects that the partial doc, upsert and script and its options are specified on the next line. Fails if it doesn't exist.
}

public extension ESClient {
    public func bulk(parameters: ESParams = [:]) throws -> ESResponse {
        let body = try parameters.enforce("body").string
        
        let query = try validateAndExtractQuery(parameters: parameters, include: ["consistency", "refresh", "replication", "type", "timeout"])
        let path = esPathify(parameters["index"], parameters["type"], "_bulk")
        return request(path: path, query: query, requestBody: body)
    }
    
    public func bulk(body: String, parameters: ESParams = [:]) throws -> ESResponse {
        var requestParams = parameters
        requestParams["body"] = ESParam(body)
        return try bulk(parameters: requestParams)
    }
    
    public func bulk(body: Data, parameters: ESParams = [:]) throws -> ESResponse {
        guard let string = String(data: body, encoding: .utf8) else { throw ESError.invalidBodyData(body) }
        return try bulk(body: string)
    }
}
