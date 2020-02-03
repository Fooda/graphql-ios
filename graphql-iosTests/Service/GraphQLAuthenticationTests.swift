//
//  GraphQLAuthenticationTests.swift
//  graphql-iosTests
//
//  Created by Jake Hergott on 1/31/20.
//  Copyright © 2020 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GraphQLAuthenticationTests: XCTestCase {
    func testEquatable() {
        XCTAssertEqual(GraphQLAuthentication.anonymous(sessionToken: nil), GraphQLAuthentication.anonymous(sessionToken: nil))
        XCTAssertEqual(GraphQLAuthentication.anonymous(sessionToken: "token"), GraphQLAuthentication.anonymous(sessionToken: "token"))
        XCTAssertEqual(GraphQLAuthentication.authenticated(sessionToken: "token"), GraphQLAuthentication.authenticated(sessionToken: "token"))
        XCTAssertNotEqual(GraphQLAuthentication.authenticated(sessionToken: "token"), GraphQLAuthentication.anonymous(sessionToken: "token"))
        XCTAssertNotEqual(GraphQLAuthentication.authenticated(sessionToken: "token"), GraphQLAuthentication.authenticated(sessionToken: "token-2"))
        XCTAssertNotEqual(GraphQLAuthentication.anonymous(sessionToken: "token"), GraphQLAuthentication.anonymous(sessionToken: "token-2"))
    }
}
