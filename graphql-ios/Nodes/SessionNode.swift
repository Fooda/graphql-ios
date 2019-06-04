//
//  SessionNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/2/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum SessionNode: GraphQLNode {
    case token
    case user([UserNode])

    public var description: String {
        var internalNodes: [GraphQLNode]?
        let base: String
        switch self {
        case .token:
            base = "token"
        case let .user(nodes):
            internalNodes = nodes
            base = "user"
        }
        return stringRepresentation(key: base, internalNodes: internalNodes)
    }
}
