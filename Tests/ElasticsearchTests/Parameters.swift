//
//  Parameters.swift
//  ElasticsearchFoundation
//
//  Created by David Monagle on 14/09/2016.
//
//

import XCTest
@testable import Elasticsearch

class ParametersTest: XCTestCase {
    var esClient : ESClient = ESClient()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultValue() {
        let params : ESParams = ["one": "1", "two": "2"]
        
        XCTAssertEqual(try params.get("one", default: "5"), "1")
        XCTAssertEqual(try params.get("three", default: "3"), "3")
    }
    
    func testPathify() {
        XCTAssertEqual(esPathify("one/", "/", "two ", "\n", "//three"), "one/two/three")
        XCTAssertEqual(esPathify("one/", "/", nil, "\n", "//three"), "one/three")
        XCTAssertEqual(esPathify("one/", "/", "", "\n", "//three"), "one/three")
        
        let indexes = ESParam(["one", "two", "three"])
        let path = esPathify(indexes, "_search")
        XCTAssertEqual(path, "one,two,three/_search")
    }

    func testListify() {
        XCTAssertEqual(esListify("A", "B"), "A,B")
        XCTAssertEqual(esListify("one", "two^three"), "one,two%5Ethree")
        
        let esParam = ESParam(["one", "two^three"])
        XCTAssertEqual(esParam.esListify().makeESParam().string, "one,two%5Ethree")

    }

//    func testFilter() {
//        let dict = ["one": "1", "two": "2", "three": "3"]
//        let filteredTwo = dict.only("two")
//        XCTAssertEqual(filteredTwo.count, 1)
//        XCTAssertEqual(filteredTwo["two"], "2")
//    }

    func testEnforceParameter() throws {
        let params : ESParams = ["one": "1", "two": "2", "three": "3"]
        try _ = params.enforce("one")
        XCTAssertThrowsError(try _ = params.enforce("five"), "five should not exist")
    }
    
    func testValidateAndExtractQuery() throws {
        
        let params : ESParams = [
            "pretty": "true",
            "field": "name",
            "mine": "special"
        ]
        

        let q2 = try esClient.validateAndExtractQuery(parameters: params, include: ["mine"])
        XCTAssertEqual(q2["mine"], "special") // The included value makes it through
        XCTAssertEqual(q2["pretty"], "true") // Common Query Parameter makes it through
        XCTAssertEqual(q2["field"], nil) // Common validates but will not end up in the query
    }
}
