//
//  GraphQLNamedOperationError.swift
// graphql
//
//  Created by Craig Olson on 5/17/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Used for analytics
// contains application level error and its corresponding query name
public struct GraphQLNamedOperationError: Encodable, CustomDictionaryLiteral {
    public let name: String
    public let error: GraphQLOperationError

    public init(name: String, error: GraphQLOperationError) {
        self.name = name
        self.error = error
    }
}
