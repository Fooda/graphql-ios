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
    private let logger = MockLogger()
    private lazy var provider = MockProvider(fullUrl: url, clientToken: "client-token")

    override func setUp() {
        super.setUp()
        logger.reset()
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

        client.configure(logger: logger, provider: provider)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.authenticated(sessionToken: "abc123")
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
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

    func testMissingProvider() {
        let body = """
                    {
                    }
                """
        client.configure(logger: logger, provider: nil)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.undefinedHost = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                XCTAssertFalse(self.logger.logs.contains(where: { $0.message == "graphql_start" }))
                XCTAssertFalse(self.logger.logs.contains(where: { $0.message == "graphql_complete" }))
                XCTAssertFalse(self.logger.logs.contains(where: { $0.message == "graphql_failure" }))
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testServerError() {
        let body = """
                    {
                    }
                """
        client.configure(logger: logger, provider: provider)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 500, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
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
        let mockProvider = MockProvider(fullUrl: "not-a-url", clientToken: "")
        client.configure(logger: logger, provider: mockProvider)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
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
        client.configure(logger: logger, provider: provider)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
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
        client.configure(logger: logger, provider: provider)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
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
        client.configure(logger: logger, provider: provider)
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous(sessionToken: nil)
        client.performOperation(request: request) { (result: Result<UnexpectedJsonResponse, Error>) in
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

        waitForExpectations(timeout: 2.0, handler: nil)    }
}
