//
//  BannerStyleNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/21/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class BannerStyleNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(BannerStyleNode.bodyTextColor.description, "bodyTextColor")
        XCTAssertEqual(BannerStyleNode.borderColor.description, "borderColor")
        XCTAssertEqual(BannerStyleNode.fillColor.description, "fillColor")
        XCTAssertEqual(BannerStyleNode.titleTextColor.description, "titleTextColor")
    }
}
