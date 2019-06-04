//
//  PhoneNumberNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/20/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum PhoneNumberNode: String, GraphQLNode {
    case digits
    case state

    public var description: String {
        return rawValue
    }
}
