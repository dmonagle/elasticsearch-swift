import XCTest
@testable import Elasticsearch

import JSON

class BulkTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBulk() throws {
        let esClient = ESClient()
        esClient.prefix = "test_es_"
        let host = URLComponents(string: "http://localhost:9200")!
        
        try esClient.addHost(host)
        let proxy = ESBulkProxy(client: esClient)
        
        try _ = esClient.deleteIndex(name: "alphabet")
        proxy.threshhold = 100000
        
        var json = JSON()
        try json.set("clone", "true")
        try json.set("data", "The quick brown fox jumps over the lazy dog.")
        for count in 1...30000 {
            try proxy.append(action: .create, index: "alphabet", type: "clone", id: "\(count)", data: json)
        }
        XCTAssertTrue(esClient.indexExists(name: "alphabet"))
        XCTAssertTrue(try esClient.count(index: "alphabet") > 0) // Can't test for the full 30,000 as the index will be running still
        
    }
}
