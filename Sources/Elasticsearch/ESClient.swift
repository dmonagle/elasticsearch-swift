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
    
    public init(settings: ESTransportSettings = ESTransportSettings()) {
        _transport = ESTransport(settings: settings)
    }
    
    public func prefixIndex(_ name: ESIndexNameable) -> ESParam {
        let prefix = name.esIndex.prefix ?? (self.prefix ?? "")
        return ESParam("\(prefix)\(name.esIndex.name)")
    }

    public func addHost(_ host: URLComponents) throws {
        try _transport.addHost(url: host)
    }
    
    public func request(method: RequestMethod = .GET, path: String = "", parameters: ESParams = [:], requestBody: String? = nil) -> ESResponse {
        return _transport.request(method: method, path: path, parameters: parameters, requestBody: requestBody)
    }

    public func request(method: RequestMethod = .GET, path: String = "", parameters: ESParams = [:], requestBody: JSONStringRepresentable? = nil) -> ESResponse {
        return _transport.request(method: method, path: path, parameters: parameters, requestBody: requestBody?.JSONString() ?? nil)
    }
}
