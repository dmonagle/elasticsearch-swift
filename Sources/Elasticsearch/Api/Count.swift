import Foundation

public extension ESClient {
    public func count(parameters: ESParams = [:]) throws -> ESResponse {
        let index = parameters["index"] ?? ESParam("_all")
        let body = parameters["body"]?.string
        let requestParams = parameters.filter(include: ["analyzer", "analyze_wildcard", "default_operator", "df",
                                                        "ignore_unavailable", "allow_no_indices", "expand_wildcards", "lenient",
                                                        "lowercase_expanded_terms", "preference", "q", "routing"])
        
        let path = esPathify(index.esListify(), parameters["type"]?.esListify(), "_count")
        
        
        return request(path: path, parameters: requestParams, requestBody: body)
    }
    
    public func count(index: ESIndexNameable, parameters: ESParams = [:]) throws -> Int {
        var requestParams = parameters
        requestParams["index"] = prefixIndex(index)
        let result = try count(parameters: requestParams)
        guard let json = result.body?.json else { return 0 }
        return json["count"]?.int ?? 0
    }
}
