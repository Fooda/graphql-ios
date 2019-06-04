//
//  GetUserNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum GetUserNode: GraphQLNode {
    case error([ErrorNode])
    case user([UserNode])

    public var description: String {
        let internalNodes: [GraphQLNode]
        let base: String
        switch self {
        case let .error(nodes):
            internalNodes = nodes
            base = "error"
        case let .user(nodes):
            internalNodes = nodes
            base = "user"
        }
        return stringRepresentation(key: base, internalNodes: internalNodes)
    }
}
