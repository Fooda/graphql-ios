//
//  ErrorNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/15/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest

@testable import graphql_ios

class ErrorNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(ErrorNode.code.description, "code")
        XCTAssertEqual(ErrorNode.message.description, "message")
    }
}
