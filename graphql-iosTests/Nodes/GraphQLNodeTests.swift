//
//  GraphQLNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/15/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLNodeTests: XCTestCase {
    struct MockNode: GraphQLNode {
        var description: String
        
        init(_ description: String = "test") {
            self.description = description
        }
    }
    
    func testStringRepresentationInternalNodes() {
        let internalNodes = [MockNode("this"), MockNode("is"), MockNode("a"), MockNode("test")]
        let node = MockNode()
        
        let result = node.stringRepresentation(key: "key", internalNodes: internalNodes)
        XCTAssertEqual(result, "key {\nthis\nis\na\ntest\n}\n")
    }
    
    func testStringRepresentationNoInternalNodes() {
        let node = MockNode()
        XCTAssertEqual(node.stringRepresentation(key: "key", internalNodes: []), "key")
    }
}
