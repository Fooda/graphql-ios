//
//  GraphQLError.swift
//  iFooda
//
//  Created by Craig Olson on 5/9/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Base level graphql error
// At the same level as "data"
public struct GraphQLError: Decodable {
    let message: String
    
    public var title: String {
        return message
    }
}
