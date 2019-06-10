//
//  CampaignBannerNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/21/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class CampaignBannerNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(CampaignBannerNode.id.description, "id")
        XCTAssertEqual(CampaignBannerNode.title.description, "title")
        XCTAssertEqual(CampaignBannerNode.content.description, "content")
        XCTAssertEqual(CampaignBannerNode.iconUrl.description, "iconUrl")
        XCTAssertEqual(CampaignBannerNode.platform.description, "platform")

        let styleNode = CampaignBannerNode.style([.fillColor])
        XCTAssertEqual(styleNode.description, styleNode.stringRepresentation(key: "style", internalNodes: [BannerStyleNode.fillColor]))
    }
}
