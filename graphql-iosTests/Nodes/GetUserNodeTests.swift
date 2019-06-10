//
//  GetUserNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class GetUserNodeTests: XCTestCase {
    func testDescription() {
        let errorNodes = [ErrorNode.code, ErrorNode.message]
        let error = GetUserNode.error(errorNodes)
        XCTAssertEqual(error.description, error.stringRepresentation(key: "error", internalNodes: errorNodes))

        let userNodes = [UserNode.id, UserNode.uuid]
        let getUser = GetUserNode.user(userNodes)
        XCTAssertEqual(getUser.description, getUser.stringRepresentation(key: "user", internalNodes: userNodes))
    }
}
