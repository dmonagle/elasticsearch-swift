//
//  ESLogDelegate.swift
//  Elasticsearch
//
//  Created by David Monagle on 3/8/17.
//
//

import Foundation

public enum ESLogLevel: String {
    case error
    case warning
    case info
    case debug
}

public protocol ESLogDelegate {
    func log(_ level: ESLogLevel, message: String)
}
