//
//  ESClient.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 25/11/16.
//
//

import Foundation

// Elasticsearch Client Class
public class ESClient {
    public var prefix : String?
    internal var _transport: ESTransport
    public var logger : ESLogDelegate?
    
    public init(settings: ESTransportSettings = ESTransportSettings(), logger: ESLogDelegate? = nil) {
        self.logger = logger
        _transport = ESTransport(settings: settings)
        _transport.logger = logger
    }
    
    public func prefixIndex(_ name: ESIndexNameable) -> ESParam {
        let prefix = name.esIndex.prefix ?? (self.prefix ?? "")
        return ESParam("\(prefix)\(name.esIndex.name)")
    }

    public func addHost(_ host: URLComponents) throws {
        try _transport.addHost(url: host)
    }
    
    public func request(method: RequestMethod = .GET, path: String = "", query: ESParams = [:], requestBody: String? = nil) -> ESResponse {
        return _transport.request(method: method, path: path, query: query, requestBody: requestBody)
    }

    public func request(method: RequestMethod = .GET, path: String = "", query: ESParams = [:], requestBody: JSONStringRepresentable? = nil) -> ESResponse {
        return _transport.request(method: method, path: path, query: query, requestBody: requestBody?.JSONString() ?? nil)
    }
    
    /// Returns the query parameters
    public func validateAndExtractQuery(parameters: ESParams, include: [String] = []) throws -> ESParams {
        let filtered = try parameters.filter {
            key, _ in
            
            let include = include.contains(key) || ES_COMMON_QUERY_PARAMETERS.contains(key)
            
            if !include && !ES_COMMON_PARAMETERS.contains(key) {
                throw ESError.invalidParameters(key: key, parameters: parameters)
            }
            
            return include
        }
        
        var result : ESParams = [:]
        
        for (key,value) in filtered { result[key] = value }
        
        return result
    }

}
