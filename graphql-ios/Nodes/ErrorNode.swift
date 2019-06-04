//
//  ErrorNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/2/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum ErrorNode: String, GraphQLNode {
    case code
    case message

    public var description: String {
        return rawValue
    }
}
