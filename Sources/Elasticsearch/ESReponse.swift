//
//  ESReponse.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 21/7/17.
//
//

import Foundation

public enum ESResponse {
    case ok(HTTPURLResponse, ESResponseBody?)
    case error(ESError)

    /// Returns true if the call was successful
    public var success: Bool {
        if case .ok = self {
            return true
        }
        return false
    }
    
    /// Returns the error if there was one, otherwise returns nil
    public var error: ESError? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    /// Returns the body of the request if the request was successful. Otherwise returns nil
    public var body : ESResponseBody? {
        if case .ok(_, let body) = self {
            return body
        }
        return nil
    }
}

