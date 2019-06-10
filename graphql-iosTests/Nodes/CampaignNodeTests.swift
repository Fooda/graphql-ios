//
//  CampaignNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/21/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class CampaignNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(CampaignNode.id.description, "id")

        let bannerNodes = [CampaignBannerNode.content]
        let banners = CampaignNode.banners(bannerNodes)

        XCTAssertEqual(banners.description, banners.stringRepresentation(key: "banners", internalNodes: bannerNodes))
    }
}
