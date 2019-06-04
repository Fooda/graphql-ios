//
//  UserNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/3/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum UserNode: GraphQLNode {
    case id
    case uuid
    case email
    case emailVerified
    case firstName
    case lastName
    case phoneNumber
    case referralCode
    case rewardsPhoneNumber([PhoneNumberNode])
    case activeCampaigns([CampaignNode])

    public var description: String {
        var internalNodes: [GraphQLNode]? = nil
        var base: String
        switch self {
        case .id:
            base = "id"
        case .uuid:
            base = "uuid"
        case .email:
            base = "email"
        case .emailVerified:
            base = "emailVerified"
        case .firstName:
            base = "firstName"
        case .lastName:
            base = "lastName"
        case .phoneNumber:
            base = "phoneNumber"
        case .referralCode:
            base = "referralCode"
        case let .rewardsPhoneNumber(nodes):
            internalNodes = nodes
            base = "rewardsPhoneNumber"
        case let .activeCampaigns(nodes):
            internalNodes = nodes
            base = "activeCampaigns"
        }
        return stringRepresentation(key: base, internalNodes: internalNodes)
    }
}
