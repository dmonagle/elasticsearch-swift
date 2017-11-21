//
//  Scroll.swift
//  Elasticsearch
//
//  Created by David Monagle on 22/11/17.
//

extension ESClient {
    public func scroll(parameters: ESParams) throws -> ESResponse {
        let query = try validateAndExtractQuery(parameters: parameters, include: ["scroll", "scroll_id"])
        let path = esPathify("_search", "scroll")
        
        return request(path: path, query: query)
    }
    
    public func scroll(id: String, parameters: ESParams = [:]) throws -> ESResponse {
        var requestParams = parameters
        requestParams["scroll_id"] = ESParam(id)
        return try scroll(parameters: requestParams)
    }
}

