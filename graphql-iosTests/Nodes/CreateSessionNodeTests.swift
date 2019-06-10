//
//  CreateSessionNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/15/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class CreateSessionNodeTests: XCTestCase {
    func testDescription() {
        let errorNodes = [ErrorNode.code, ErrorNode.message]
        let error = CreateSessionNode.error(errorNodes)
        XCTAssertEqual(error.description, error.stringRepresentation(key: "error", internalNodes: errorNodes))
        
        let sessionNodes = [SessionNode.token, SessionNode.user([])]
        let session = CreateSessionNode.session(sessionNodes)
        XCTAssertEqual(session.description, session.stringRepresentation(key: "session", internalNodes: sessionNodes))
    }
}
