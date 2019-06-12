//
//  GraphQLNode.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/2/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public protocol GraphQLNode: CustomStringConvertible {}

extension GraphQLNode {
    public func stringRepresentation(key: String, internalNodes: [GraphQLNode]?) -> String {
        if let internalNodes = internalNodes, !internalNodes.isEmpty {
            let internalString = internalNodes.map { $0.description }.joined(separator: "\n")
            return key + " {\n" + internalString + "\n}\n"
        } else {
            return key
        }
    }
}
