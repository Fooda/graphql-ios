//
//  PhoneNumberNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/20/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class PhoneNumberNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(PhoneNumberNode.digits.description, "digits")
        XCTAssertEqual(PhoneNumberNode.state.description, "state")
    }
}
