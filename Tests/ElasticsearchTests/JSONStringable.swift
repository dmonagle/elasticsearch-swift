//
//  JSONStringable.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 21/7/17.
//
//

import XCTest
@testable import Elasticsearch

class JsonStringableTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDictionary() throws {
        let dict : Dictionary<String,Any> = ["hello": "yes", "number": 1]
        XCTAssertEqual(dict.JSONString(pretty: false), "{\"hello\":\"yes\",\"number\":1}")
    }
}
 
