//
//  UserNodeTests.swift
//  iFoodaTests
//
//  Created by Craig Olson on 5/15/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import XCTest
@testable import graphql_ios

class UserNodeTests: XCTestCase {
    func testDescription() {
        XCTAssertEqual(UserNode.id.description, "id")
        XCTAssertEqual(UserNode.uuid.description, "uuid")
        XCTAssertEqual(UserNode.email.description, "email")
        XCTAssertEqual(UserNode.emailVerified.description, "emailVerified")
        XCTAssertEqual(UserNode.firstName.description, "firstName")
        XCTAssertEqual(UserNode.lastName.description, "lastName")
        XCTAssertEqual(UserNode.phoneNumber.description, "phoneNumber")
        XCTAssertEqual(UserNode.referralCode.description, "referralCode")

        let rewards = UserNode.rewardsPhoneNumber([.digits, .state])
        XCTAssertEqual(rewards.description, rewards.stringRepresentation(key: "rewardsPhoneNumber", internalNodes: [PhoneNumberNode.digits, PhoneNumberNode.state]))

        let campaigns = UserNode.activeCampaigns([.id])
        XCTAssertEqual(campaigns.description, campaigns.stringRepresentation(key: "activeCampaigns", internalNodes: [CampaignNode.id]))
    }
}
