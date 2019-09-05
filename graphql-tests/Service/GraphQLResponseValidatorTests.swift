//
//  GraphQLResponseValidatorTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLResponseValidatorTests: XCTestCase {
    let validator = GraphQLResponseValidator()

    func testInvalidCredentials() {
        do {
            try validator.validateResponse(statusCode: 401, responseError: nil)
            XCTFail("Expected success")
        } catch {
            XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.invalidCredentials.localizedDescription)
        }

        do {
            try validator.validateResponse(statusCode: 403, responseError: nil)
            XCTFail("Expected success")
        } catch {
            XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.invalidCredentials.localizedDescription)
        }
    }

    func testServerError() {
        do {
            try validator.validateResponse(statusCode: 500, responseError: nil)
            XCTFail("Expected success")
        } catch {
            XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.serverError(statusCode: 500).localizedDescription)
        }
    }

    func testNetworkError() {
        let urlError = URLError(.badURL)
        do {
            try validator.validateResponse(statusCode: 0, responseError: urlError)
            XCTFail("Expected success")
        } catch {
            XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.networkError(urlError).localizedDescription)
        }
    }

    func testGenericError() {
        do {
            try validator.validateResponse(statusCode: 0, responseError: GraphQLRemoteError.undefinedHost)
            XCTFail("Expected success")
        } catch {
            XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.undefinedHost.localizedDescription)
        }
    }

    func testUnknownError() {
        do {
            try validator.validateResponse(statusCode: 0, responseError: nil)
            XCTFail("Expected success")
        } catch {
            XCTAssertEqual(error.localizedDescription, GraphQLRemoteError.unknown.localizedDescription)
        }
    }
}
