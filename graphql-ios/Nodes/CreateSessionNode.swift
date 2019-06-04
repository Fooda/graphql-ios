//
//  CreateSessionNode.swift
//  iFooda
//
//  Created by Craig Olson on 5/2/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public enum CreateSessionNode: GraphQLNode {
    case error([ErrorNode])
    case session([SessionNode])

    public var description: String {
        let internalNodes: [GraphQLNode]
        let base: String
        switch self {
        case let .error(nodes):
            internalNodes = nodes
            base = "error"
        case let .session(nodes):
            internalNodes = nodes
            base = "session"
        }
        return stringRepresentation(key: base, internalNodes: internalNodes)
    }
}
