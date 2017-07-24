public extension ESClient {
    public func get(parameters: ESParams = [:]) throws -> ESResponse {
        let index = try parameters.enforce("index")
        let id = try parameters.enforce("id")
        let type = try parameters.get("type", default: "_all")
        
        let requestParams = parameters.filter(include: [
            "fields", "parent", "preference", "realtime", "refresh", "routing", "version", "version_type",
            "_source", "_source_include", "_source_exclude", "_source_transform"])
        
        let path = esPathify(index, type, id)
        return request(path: path, parameters: requestParams)
    }
    
    public func get(index: ESIndexNameable, type: String? = nil, id: String) throws -> ESResponse  {
        var parameters : ESParams = ["index": ESParam(prefixIndex(index)), "id": ESParam(id)]
        if let type = type {
            parameters["type"] = ESParam(type)
        }
        return try get(parameters: parameters)
    }
    
    public func search(parameters: ESParams = [:], body: String) throws -> ESResponse {
        let index = try parameters.get("index", default: "_all")
        let type = parameters["type"]
        let requestParams = parameters.filter(include: [
            "analyzer", "analyze_wildcard", "default_operator", "df", "explain", "fielddata_fields", "docvalue_fields", "stored_fields", "fields", "from", "ignore_indices", "ignore_unavailable", "allow_no_indices", "expand_wildcards", "lenient", "lowercase_expanded_terms", "preference", "q", "query_cache", "request_cache", "routing", "scroll", "search_type", "size", "sort", "source", "_source", "_source_include", "_source_exclude", "stored_fields", "stats", "suggest_field", "suggest_mode", "suggest_size", "suggest_text", "terminate_after", "timeout", "typed_keys", "version", "batched_reduce_size", "max_concurrent_shard_requests", "pre_filter_shard_size"])
        
        let path = esPathify(prefixIndex(index), type, "_search")
        return request(method: .POST, path: path, parameters: requestParams, requestBody: body)
    }
    
    public func search(index: ESIndexNameable? = nil, type: String? = nil, body: String) throws -> ESResponse {
        let path = esPathify(index != nil ? prefixIndex(index!) : nil, type, "_search")
        return request(method: .POST, path: path, requestBody: body)
    }
}
