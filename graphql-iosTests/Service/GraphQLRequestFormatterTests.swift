//
//  GraphQLRequestFormatterTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLRequestFormatterTests: XCTestCase {
    let formatter = GraphQLRequestFormatter()
    let operation = MockOperation.anonymous

    func testRequestBodyEmptyParameters() {
        var json = formatter.requestBody(operation, parameters: nil)
        XCTAssertEqual(json["query"] as? String, operation.description)
        XCTAssertNil(json["variables"])
    }

    func testRequestBodyParameterBody() {
        let parameters = GraphQLParameters.base([
            "name": "test"
            ])
        let json = formatter.requestBody(operation, parameters: parameters)
        XCTAssertEqual(json["query"] as? String, operation.description)
        guard let variables = json["variables"] as? [String: Any] else {
            return XCTFail("Failed request format")
        }
        XCTAssertEqual(variables["name"] as? String, "test")
    }

    func testRequestBodyParameterInput() {
        let parameters = GraphQLParameters.input([
            "name": "test",
            "message": "t"
            ])
        let json = formatter.requestBody(operation, parameters: parameters)
        XCTAssertEqual(json["query"] as? String, operation.description)
        guard let variables = json["variables"] as? [String: Any],
            let input = variables["input"] as? [String: Any] else {
                return XCTFail("Failed request format")
        }
        XCTAssertEqual(input["name"] as? String, "test")
        XCTAssertEqual(input["message"] as? String, "t")
    }
}
