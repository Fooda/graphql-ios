//
//  GraphQLRemoteErrorTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql

class GraphQLRemoteErrorTests: XCTestCase {
    private let defaultMessage = "We’re having trouble connecting to Fooda, try again in a few minutes. If the problem persists, please contact support. We apologize for this inconvenience.".localized()
    private lazy var apiErrors: [GraphQLError] = (0..<2).map { GraphQLError(message: "\($0)") }
    private lazy var graphQLErrors: [GraphQLNamedOperationError] = (0..<2).map {
        GraphQLNamedOperationError(name: "\($0)", error: GraphQLOperationError(code: 200, message: "GraphQLError\($0)"))
    }
    private let urlError: URLError = NSError(domain: NSURLErrorDomain,
                                             code: URLError.timedOut.rawValue,
                                             userInfo: [NSLocalizedDescriptionKey: "The request timed out."]) as! URLError

    func testErrorDescription() {
        XCTAssertEqual(GraphQLRemoteError.invalidCredentials.errorDescription, "Invalid credentials")

        XCTAssertEqual(GraphQLRemoteError.serverError(statusCode: 500).errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.protocolError(statusCode: 401, errors: []).errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.protocolError(statusCode: 403, errors: apiErrors).errorDescription, apiErrors.first?.message)
        XCTAssertEqual(GraphQLRemoteError.networkError(urlError).errorDescription, urlError.localizedDescription)
        XCTAssertEqual(GraphQLRemoteError.unexpectedJSON.errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.operationErrors(graphQLErrors).errorDescription, graphQLErrors.first?.error.message)
        XCTAssertEqual(GraphQLRemoteError.operationErrors([]).errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.undefinedHost.errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.unknown.errorDescription, defaultMessage)
    }

    func testDebugDescription() {
        XCTAssertEqual(GraphQLRemoteError.invalidCredentials.debugDescription, "invalid_credentials")

        XCTAssertEqual(GraphQLRemoteError.serverError(statusCode: 502).debugDescription, "server_502")
        XCTAssertEqual(GraphQLRemoteError.protocolError(statusCode: 401, errors: []).debugDescription, "protocol_error")
        XCTAssertEqual(GraphQLRemoteError.protocolError(statusCode: 403, errors: apiErrors).debugDescription, "protocol_error")
        XCTAssertEqual(GraphQLRemoteError.networkError(urlError).debugDescription, "network_\((urlError as NSError).debugDescription)")

        XCTAssertEqual(GraphQLRemoteError.unexpectedJSON.debugDescription, "unexpected_json")
        XCTAssertEqual(GraphQLRemoteError.operationErrors(graphQLErrors).debugDescription, "operation_error")
        XCTAssertEqual(GraphQLRemoteError.undefinedHost.debugDescription, "undefined_host")
        XCTAssertEqual(GraphQLRemoteError.unknown.debugDescription, "unknown_error")
    }
}
