//
//  BannerStyleNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/21/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum BannerStyleNode: String, GraphQLNode {
    case bodyTextColor
    case borderColor
    case fillColor
    case titleTextColor

    public var description: String {
        return rawValue
    }
}
