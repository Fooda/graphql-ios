//
//  GraphQLPayload.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/7/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// GraphQL response nested inside of "data"
public protocol GraphQLPayload: Decodable {
    var errors: [GraphQLOperationError] { get }
}
