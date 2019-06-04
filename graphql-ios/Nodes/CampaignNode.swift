//
//  CampaignNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/21/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum CampaignNode: GraphQLNode {
    case id
    case banners([CampaignBannerNode])

    public var description: String {
        var internalNodes: [GraphQLNode]?
        let base: String
        switch self {
        case .id:
            base = "id"
        case let .banners(nodes):
            internalNodes = nodes
            base = "banners"
        }

        return stringRepresentation(key: base, internalNodes: internalNodes)
    }
}
