//
//  GraphQLClientTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

// Mock response that is simple to decode
struct MockResponse: Decodable {

}

// Mock response that throws `GraphQLRemoteError.unexpectedJSON` when the response is empty
struct UnexpectedJsonResponse: Decodable {
    let result: Result?

    struct Result: Decodable {

    }
}

class GraphQLClientTests: XCTestCase {
    private let client = GraphQLClient.shared
    private let url = "api.fooda.com/graphql"
    private let clientToken = "client-token"
    private let logger = MockLogger()

    override func setUp() {
        super.setUp()
        logger.reset()
        client.configure(logger: logger)
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

        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.authenticated(sessionToken: "abc123")
        client.performOperation(url: url, clientToken: clientToken, request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertFalse(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            case let .failure(error):
                XCTFail("Expected success: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testServerError() {
        let body = """
                    {
                    }
                """
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 500, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(url: url, clientToken: clientToken, request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.serverError = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testNetworkError() {
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(url: "not-a-url", clientToken: clientToken, request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.networkError = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDecodingError() {
        // Decoding error is triggered by failing to decode `GraphQLProtocolError`.  Missing field `message`.
        let body = """
                    {
                      "errors": [
                        {
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

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(url: url, clientToken: clientToken, request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard error is DecodingError else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testProtocolError() {
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

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(url: url, clientToken: clientToken, request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.protocolError = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testUnexpectedJsonError() {
        let body = """
                    {
                    }
                """
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(url: url, clientToken: clientToken, request: request) { (result: Result<UnexpectedJsonResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.unexpectedJSON = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertTrue(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
