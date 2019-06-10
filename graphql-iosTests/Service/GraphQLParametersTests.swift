//
//  GraphQLParametersTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLParametersTests: XCTestCase {
    func testDictionary() {
        let base = GraphQLParameters.base(["test": "value",
                                           "test2": "value2"
            ])
        let baseDictionary = base.dictionary
        XCTAssertEqual(baseDictionary["test"] as? String, "value")
        XCTAssertEqual(baseDictionary["test2"] as? String, "value2")

        let inputNode = GraphQLParameters.input(["test": "value",
                                                 "test2": "value2"
            ])
        let inputDictionary = inputNode.dictionary
        guard let input = inputDictionary["input"] as? [String: Any] else {
            return XCTFail("unexpecteed json")
        }
        XCTAssertEqual(input["test"] as? String, "value")
        XCTAssertEqual(input["test2"] as? String, "value2")
    }
}
