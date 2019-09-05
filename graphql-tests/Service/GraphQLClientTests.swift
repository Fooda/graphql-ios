//
//  GraphQLClientTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql

class GraphQLClientTests: XCTestCase {
    private lazy var client = GraphQLClient.shared
    private lazy var url = "api.fooda.com/graphql"

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

        let request = MockRequest.authenticated
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
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

        let request = MockRequest.authenticated
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.invalidCredentials = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testInvalidResponse() {
        let body = "{}"
        StubManager.shared.stub(url: url, method: "post", responseStatusCode: 200, responseBody: body)
        let promise = expectation(description: "Wait for client")

        let request = MockRequest.anonymous
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure:
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

        let request = MockRequest.anonymous
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.protocolError = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
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

        let request = MockRequest.anonymous
        client.performOperation(request: request) { (result: Result<MockResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case let .failure(error):
                guard case GraphQLRemoteError.invalidCredentials = error else {
                    XCTFail("Unexpected error: \(error.localizedDescription)")
                    return
                }
                promise.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
