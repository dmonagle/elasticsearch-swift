//
//  ESTransport.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 14/09/2016.
//
//

import Foundation
import Dispatch

public enum RequestMethod : String {
    case HEAD
    case GET
    case POST
    case PUT
    case DELETE
}

public struct ESTransportSettings {
    public var retryOnFailure : Bool
    public var reloadAfter : Int /// Requests
    public var resurrectAfter : Int /// Seconds
    public var maxRetries : Int /// Requests
    public var baseConnectionTimeout : TimeInterval /// The base time a connection stays dead for
    public var requestTimeout : TimeInterval /// Timeout for each HTTPRequest
    
    public init(retryOnFailure : Bool = true, reloadAfter : Int = 1000, resurrectAfter : Int = 60, maxRetries : Int = 3, baseConnectionTimeout : TimeInterval = 60, requestTimeout : TimeInterval = 15) {
        self.retryOnFailure = retryOnFailure
        self.reloadAfter = reloadAfter
        self.resurrectAfter = resurrectAfter
        self.maxRetries = maxRetries
        self.baseConnectionTimeout = baseConnectionTimeout
        self.requestTimeout = requestTimeout
    }
}

open class ESTransport {
    public var transportProtocol : String = "http"
    public var logger : ESLogDelegate? = nil
    internal var _hosts : [URLComponents] = []
    internal var _connectionPool : ConnectionPool = ConnectionPool()
    internal var _connectionCounter : Int = 0
    internal var _settings : ESTransportSettings
    internal let session = URLSession(configuration: URLSessionConfiguration.default)
    
    public init(settings: ESTransportSettings? = nil) {
        if let s = settings {
            _settings = s
        }
        else {
            _settings = ESTransportSettings()
        }
        _connectionPool = ConnectionPool()
    }
    
    public func addConnection(_ connection: ESConnection) throws {
        try _connectionPool.add(connection: connection)
    }
    
    public func addHost(url: URLComponents) throws {
        try addConnection(ESConnection(url: url, baseTimeout: _settings.baseConnectionTimeout))
    }
    
    public func addHost(string: String) throws {
        if let url = URLComponents(string: string) {
            try addHost(url: url)
        }
    }
    
    
    internal func buildConnections() {
        _connectionPool = ConnectionPool()
        _connectionCounter = 0
        for host in _hosts {
            try? addHost(url: host)
        }
    }
    
    /**
     Returns a connection from the connection pool by delegating to Collection.
     
     Resurrects dead connection if the resurrectAfter timeout has passed.
     Increments the counter and performs connection reloading if the `reload_connections` option is set.
     
     - returns: ESConnection
     */
    public func getConnection() -> ESConnection? {
        if (_connectionPool.length == 0) { buildConnections() }
        // Reload connections if we've hit the reloadAfter
        if (_settings.reloadAfter != 0 && (_connectionCounter >= _settings.reloadAfter)) {
            sniffConnections()
        }
        
        if let connection = _connectionPool.nextConnection() {
            _connectionCounter += 1
            
            
            return connection;
        }
        
        return nil
    }
    
    /// Reloads and replaces the connection collection based on cluster information.
    public func sniffConnections() {
        let sniffer = ESSniffer(transport: self)
        let hosts = sniffer.hosts()
        if (hosts.count > 0) { _hosts = hosts }
        buildConnections();
    }
    
    /// Tries to "resurrect" all eligible dead connections.
    ///
    /// @see Connections::ESConnection///resurrect!
    ///
    internal func resurrectDeadConnections() {
        for connection in _connectionPool.deadConnections {
            connection.resurrect();
        }
    }
    
    /**
     Makes an asynchronous request and calls the callback method, passing in the `ESResponse`
     **/
    public func request(connection: ESConnection? = nil, method: RequestMethod, path: String = "", query: ESParams = [:], requestBody: String? = nil, callback: @escaping (ESResponse) -> ()) {
        if let connection = connection ?? getConnection() {
            var urlComponents = connection.host
            //urlComponents.path = urlComponents.path.app
            urlComponents.query = query.queryString()
            if let url = urlComponents.url {
                let requestURL = url.appendingPathComponent(path)
                var request = URLRequest(url: requestURL)
                request.httpMethod = method.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = _settings.requestTimeout

                logger?.log(.info, message: "\(method) \(path)?\(query.queryString())")

                if let body = requestBody {
                    if body.characters.count > 0 {
                        request.httpBody = body.data(using: .utf8)
                        // As there is an issue sending a body with a GET, we take the advice of Elasticsearch and change the request to a .POST
                        //
                        // From https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html
                        // Both HTTP GET and HTTP POST can be used to execute search with body. Since not all clients support GET with body, POST is allowed as well.
                        if (method == .GET) {
                            logger?.log(.debug, message: "Changing GET to POST as there is a request body")
                            request.httpMethod = "POST"
                        }
                        
                        if body.lengthOfBytes(using: .utf8) <= 1024 {
                            logger?.log(.debug, message: "Request body:\n\(body)")
                        }
                        else {
                            logger?.log(.debug, message: "Request body not logged as it is greater that 1024 bytes")
                        }
                    }
                }
                
                
                let task = session.dataTask(with: request) {
                    (data, response, error) in
                    if let error = error {
                        callback(.error(.requestError(response, error, data)))
                    }
                    else {
                        if let httpResponse = response as? HTTPURLResponse {
                            switch(httpResponse.statusCode) {
                            case 200..<300:
                                if let data = data {
                                    callback(.ok(httpResponse, ESResponseBody(data: data)))
                                }
                                else {
                                    callback(.ok(httpResponse, nil))
                                }
                            default:
                                if let data = data {
                                    callback(.error(.apiError(httpResponse, ESResponseBody(data: data))))
                                }
                                else {
                                    callback(.error(.apiError(httpResponse, nil)))
                                }
                            }
                            
                        }
                        else {
                            callback(.error(.invalidHttpResponse(response)))
                        }
                    }
                }
                task.resume()
            }
            else {
                callback(.error(ESError.invalidURL(urlComponents)))
            }
        }
        else {
            callback(.error(ESError.noConnectionsAvailable))
        }
    }
    
    public func request(connection: ESConnection? = nil, method: RequestMethod, path: String = "", query: ESParams = [:], requestBody: String? = nil) -> ESResponse {
        var result : ESResponse?
        let semaphore = DispatchSemaphore(value: 0)
        
        var retries = 0
        
        repeat {
            request(connection: connection, method: method, path: path, query: query, requestBody: requestBody) {
                response in
                switch response {
                case .error(let error):
                    self.logger?.log(.error, message: error.description)

                    switch error {
                    case .apiError(_, _):
                        // Do not retry for these error types
                        result = response // No more retrying
                    default:
                        // Retry
                        if (!self._settings.retryOnFailure || retries == self._settings.maxRetries) {
                            self.logger?.log(.error, message: "Max retries reached")

                            result = response // No more retrying
                        }
                        else {
                            retries += 1
                            self.logger?.log(.warning, message: "Retrying request \(retries)")
                        }
                    }
                default:
                    result = response
                }
                
                semaphore.signal()
            }
            semaphore.wait()
        } while (result == nil)
        
        return result!
    }
}

