//
//  GraphQLProtocolError.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/9/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Base level graphql error
// At the same level as "data"
public struct GraphQLProtocolError: Decodable {
    let message: String
}
