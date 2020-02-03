//
//  GraphQLRemoteErrorTests.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLRemoteErrorTests: XCTestCase {
    private let defaultMessage = "We’re having trouble connecting to Fooda, try again in a few minutes. If the problem persists, please contact support. We apologize for this inconvenience.".localized()
    private lazy var apiErrors: [GraphQLProtocolError] = (0..<2).map { GraphQLProtocolError(message: "\($0)") }
    private let urlError: URLError = NSError(domain: NSURLErrorDomain,
                                             code: URLError.timedOut.rawValue,
                                             userInfo: [NSLocalizedDescriptionKey: "The request timed out."]) as! URLError

    func testErrorDescription() {
        XCTAssertEqual(GraphQLRemoteError.serverError(httpStatusCode: 500).errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.protocolError(httpStatusCode: 401, errors: []).errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.protocolError(httpStatusCode: 403, errors: apiErrors).errorDescription, apiErrors.first?.message)
        XCTAssertEqual(GraphQLRemoteError.networkError(urlError).errorDescription, urlError.localizedDescription)
        XCTAssertEqual(GraphQLRemoteError.unexpectedJSON(httpStatusCode: 200).errorDescription, defaultMessage)
        XCTAssertEqual(GraphQLRemoteError.unknown.errorDescription, defaultMessage)
    }

    func testDebugDescription() {
        XCTAssertEqual(GraphQLRemoteError.serverError(httpStatusCode: 502).debugDescription, "server_502")
        XCTAssertEqual(GraphQLRemoteError.protocolError(httpStatusCode: 401, errors: []).debugDescription, "protocol_error")
        XCTAssertEqual(GraphQLRemoteError.protocolError(httpStatusCode: 403, errors: apiErrors).debugDescription, "protocol_error")
        XCTAssertEqual(GraphQLRemoteError.networkError(urlError).debugDescription, "network_\((urlError as NSError).debugDescription)")

        XCTAssertEqual(GraphQLRemoteError.unexpectedJSON(httpStatusCode: 200).debugDescription, "unexpected_json")
        XCTAssertEqual(GraphQLRemoteError.unknown.debugDescription, "unknown_error")
    }

    func testHTTPStatusCode() {
        XCTAssertEqual(GraphQLRemoteError.serverError(httpStatusCode: 502).httpStatusCode, 502)
        XCTAssertEqual(GraphQLRemoteError.protocolError(httpStatusCode: 403, errors: apiErrors).httpStatusCode, 403)
        XCTAssertEqual(GraphQLRemoteError.networkError(urlError).httpStatusCode, 0)

        XCTAssertEqual(GraphQLRemoteError.unexpectedJSON(httpStatusCode: 200).httpStatusCode, 200)
        XCTAssertEqual(GraphQLRemoteError.unknown.httpStatusCode, 0)
    }
}
