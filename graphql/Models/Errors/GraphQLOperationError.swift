//
//  GraphQLOperationError.swift
// graphql
//
//  Created by Craig Olson on 4/29/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Query/operation level GraphQL error
public struct GraphQLOperationError: Equatable, Codable {
    public let code: Int
    public let message: String

    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}
