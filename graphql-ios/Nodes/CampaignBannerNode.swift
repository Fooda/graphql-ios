//
//  CampaignBannerNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/21/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum CampaignBannerNode: GraphQLNode {
    case id
    case title
    case content
    case iconUrl
    case platform
    case style([BannerStyleNode])

    public var description: String {
        var internalNodes: [GraphQLNode]?
        let base: String
        switch self {
        case .id:
            base = "id"
        case .title:
            base = "title"
        case .content:
            base = "content"
        case .iconUrl:
            base = "iconUrl"
        case .platform:
            base = "platform"
        case let .style(nodes):
            base = "style"
            internalNodes = nodes
        }

        return stringRepresentation(key: base, internalNodes: internalNodes)
    }
}
