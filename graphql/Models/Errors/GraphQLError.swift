//
//  GraphQLError.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/9/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Base level graphql error
// At the same level as "data"

import Foundation

public struct GraphQLError: Decodable {
    let message: String
}
