//
//  Bulk.swift
//  Elasticsearch
//
//  Created by David Monagle on 23/7/17.
//

import Foundation
import JSON

public enum ESBulkAction: String {
    case index
    case create
    case delete
    case update
}

public extension ESClient {
    public func bulk(parameters: ESParams = [:]) throws -> ESResponse {
        let body = try parameters.enforce("body").string
        
        let query = try validateAndExtractQuery(parameters: parameters, include: ["consistency", "refresh", "replication", "type", "timeout"])
        
        let path = esPathify(parameters["index"], parameters["index"], "_bulk")
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
