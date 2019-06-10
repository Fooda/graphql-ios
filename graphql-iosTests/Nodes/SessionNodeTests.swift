//
//  SessionNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/15/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class SessionNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(SessionNode.token.description, "token")
        
        let userNodes = [UserNode.id, UserNode.firstName]
        let user = SessionNode.user(userNodes)
        XCTAssertEqual(user.description, user.stringRepresentation(key: "user", internalNodes: userNodes))
    }
}
