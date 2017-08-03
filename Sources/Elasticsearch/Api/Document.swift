public extension ESClient {
    public func get(parameters: ESParams = [:]) throws -> ESResponse {
        let index = try parameters.enforce("index")
        let id = try parameters.enforce("id")
        let type = try parameters.get("type", default: "_all")
        
        let query = try validateAndExtractQuery(parameters: parameters, include: [
            "fields", "parent", "preference", "realtime", "refresh", "routing", "version", "version_type",
            "_source", "_source_include", "_source_exclude", "_source_transform"])
        
        let path = esPathify(index, type, id)
        return request(path: path, query: query)
    }
    
    public func get(index: ESIndexNameable, type: String? = nil, id: String) throws -> ESResponse  {
        var parameters : ESParams = ["index": ESParam(prefixIndex(index)), "id": ESParam(id)]
        if let type = type {
            parameters["type"] = ESParam(type)
        }
        return try get(parameters: parameters)
    }
    
    public func search(parameters: ESParams, body: JSONStringRepresentable) throws -> ESResponse {
        let index = try parameters.get("index", default: "_all")
        let type = parameters["type"]
        let query = try validateAndExtractQuery(parameters: parameters, include: [
            "analyzer", "analyze_wildcard", "default_operator", "df", "explain", "fielddata_fields", "docvalue_fields", "stored_fields", "fields", "from", "ignore_indices", "ignore_unavailable", "allow_no_indices", "expand_wildcards", "lenient", "lowercase_expanded_terms", "preference", "q", "query_cache", "request_cache", "routing", "scroll", "search_type", "size", "sort", "source", "_source", "_source_include", "_source_exclude", "stored_fields", "stats", "suggest_field", "suggest_mode", "suggest_size", "suggest_text", "terminate_after", "timeout", "typed_keys", "version", "batched_reduce_size", "max_concurrent_shard_requests", "pre_filter_shard_size"])
        
        let path = esPathify(index, type, "_search")
        return request(method: .POST, path: path, query: query, requestBody: body)
    }
    
    /// Search a single index, or all indices
    public func search(index: ESIndexNameable? = nil, type: String? = nil, body: JSONStringRepresentable, parameters: ESParams = [:]) throws -> ESResponse {
        var requestParams = parameters
        if let index = index { requestParams["index"] = prefixIndex(index) }
        if let type = type { requestParams["type"] = ESParam(type) }

        return try search(parameters: requestParams, body: body)
    }
    
    public func index(parameters: ESParams = [:], body: JSONStringRepresentable) throws -> ESResponse {
        let index = try parameters.enforce("index")
        let type = try parameters.enforce("type")

        let id = parameters["id"]
        let method : RequestMethod = (id != nil ? .PUT : .POST)
        let query = try validateAndExtractQuery(parameters: parameters, include: ["consistency", "op_type", "parent", "percolate", "refresh", "replication", "routing",
                                                        "timeout", "timestamp", "ttl", "version", "version_type"])
        let path = esPathify(index, type, id)
        
        return request(method: method, path: path, query: query, requestBody: body)
    }
    
    
    public func index(index: ESIndexNameable, type: String, data: JSONStringRepresentable, parameters: ESParams = [:]) throws -> ESResponse {
        var requestParams = parameters
        requestParams["index"] = prefixIndex(index)
        requestParams["type"] = ESParam(type)
        
        return try self.index(parameters: requestParams, body: data)
    }
    
    public func index(_ indexable: ESIndexable, in context: ESContext? = nil, parameters: ESParams = [:]) throws -> ESResponse {
        var requestParams = parameters
        requestParams["id"] = ESParam(indexable.esId)
        return try self.index(index: indexable.esIndex, type: indexable.esType, data: indexable.serializeES(in: context), parameters: requestParams)
    }
}
