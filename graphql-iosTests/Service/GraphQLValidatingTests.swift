//
//  GraphQLValidatingTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLValidatingTests: XCTestCase {
    struct MockResponse: GraphQLPayload, GraphQLValidating {
        var errors: [GraphQLNamedOperationError]

        init(errors: [GraphQLNamedOperationError]) {
            self.errors = errors
        }

        init(from decoder: Decoder) throws {
            throw GraphQLRemoteError.unexpectedJSON
        }
    }

    func testValidateResponseInvalidCredentials() {
        let response = MockResponse(errors: [GraphQLNamedOperationError(name: "1", error: GraphQLOperationError(code: 401, message: "message")),
                                             GraphQLNamedOperationError(name: "2", error: GraphQLOperationError(code: 503, message: ""))])
        do {
            try response.validateResponse()
            XCTFail("Expected failure")
        } catch {
            guard let remoteError = error as? GraphQLRemoteError,
                case .invalidCredentials = remoteError else {
                    XCTFail("Expected remote error")
                    return
            }
            XCTAssertTrue(true)
        }
    }

    func testValidateResponseSiteMaintenance() {
        let response = MockResponse(errors: [GraphQLNamedOperationError(name: "1", error: GraphQLOperationError(code: 503, message: "message")),
                                             GraphQLNamedOperationError(name: "2", error: GraphQLOperationError(code: 401, message: ""))])
        do {
            try response.validateResponse()
            XCTFail("Expected failure")
        } catch {
            guard let remoteError = error as? GraphQLRemoteError,
                case .siteMaintenance = remoteError else {
                    XCTFail("Expected remote error")
                    return
            }
            XCTAssertTrue(true)
        }
    }

    func testValidateClientError() {
        let allErrors = [GraphQLNamedOperationError(name: "1", error: GraphQLOperationError(code: 400, message: "message")),
                         GraphQLNamedOperationError(name: "2", error: GraphQLOperationError(code: 503, message: ""))]
        let response = MockResponse(errors: allErrors)
        do {
            try response.validateResponse()
            XCTFail("Expected failure")
        } catch {
            guard let remoteError = error as? GraphQLRemoteError,
                case let .operationErrors(graphQlErrors) = remoteError else {
                    XCTFail("Expected remote error")
                    return
            }
            XCTAssertEqual(graphQlErrors.map { $0.error }, allErrors.map { $0.error })
        }
    }

    func validateSuccess() {
        let response = MockResponse(errors: [])
        do {
            try response.validateResponse()
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected success")
        }
    }
}
