//
//  GraphQLError.swift
//  iFooda
//
//  Created by Craig Olson on 5/9/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Base level graphql error
// At the same level as "data"
public struct GraphQLError: APIError, Decodable {
    let message: String
    
    var title: String {
        return message
    }
}
