//
//  GraphQLClientTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLClientTests: XCTestCase {
    private lazy var client = GraphQLClient.shared
    private lazy var url = "api.fooda.com/graphql"

    enum MockOperation: GraphQLOperation {
        case authenticated
        case anonymous

        var type: GraphQLOperationType { return .query }
        var name: String { return "query" }
        var description: String { return "" }

        var authentication: GraphQLAuthentication {
            switch self {
            case .anonymous:
                return .anonymous
            case .authenticated:
                return .authenticated
            }
        }
    }

    struct MockResponse: GraphQLPayload {
        struct DecodableResult: GraphQLDecodable {
            var error: GraphQLOperationError?
            var text: String?
        }

        let result: DecodableResult
        var errors: [GraphQLNamedOperationError] {
            var errors = [GraphQLNamedOperationError]()
            if let error = result.error {
                errors.append(GraphQLNamedOperationError(name: "result", error: error))
            }
            return errors
        }
    }

    override func setUp() {
        super.setUp()
        client.configure(logger: MockLogger(), provider: MockProvider())
    }

    func testSuccessResponse() {
        let body = """
            {
                "data": {
                    "result": {
                        "text": "test!",
                        "error": null
                    }
                }
            }
        """

        let provider = MockProvider(sessionToken: "abc123")
        client.configure(logger: MockLogger(), provider: provider)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let operation = MockOperation.authenticated
        client.performOperation(operation) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                promise.fulfill()
            case .failure:
                XCTFail("Expected success")
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testInvalidRequestHeader() {
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200)
        let promise = expectation(description: "Wait for client")

        let operation = MockOperation.authenticated
        client.performOperation(operation) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.invalidCredentials.localizedDescription)
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testInvalidResponse() {
        let body = "{}"
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let operation = MockOperation.anonymous
        client.performOperation(operation) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure:
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testInvalidStatusCode() {
        let body = """
            {
              "errors": [
                {
                  "message": "test",
                  "locations": [
                    {
                      "line": 1,
                      "column": 20
                    }
                  ]
                }
              ]
            }
        """
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 503, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let operation = MockOperation.anonymous
        client.performOperation(operation) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.siteMaintenance.localizedDescription)
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testBaseErrorsStatusCode200() {
        let body = """
            {
              "errors": [
                {
                  "message": "test",
                  "locations": [
                    {
                      "line": 1,
                      "column": 20
                    }
                  ]
                }
              ]
            }
        """
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let operation = MockOperation.anonymous
        client.performOperation(operation) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.protocolError(statusCode: 200, errors: [GraphQLError(message: "test")]).localizedDescription)
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testResultOperationErrors() {
        let body = """
            {
                "data": {
                    "result": {
                        "error": {
                            "code": 401,
                            "message": "invalid credentials"
                        }
                    }
                }
            }
        """
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let operation = MockOperation.anonymous
        client.performOperation(operation) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.invalidCredentials.localizedDescription)
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
