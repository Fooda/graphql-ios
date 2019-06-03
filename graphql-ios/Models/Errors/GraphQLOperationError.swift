//
//  GraphQLOperationError.swift
//  iFooda
//
//  Created by Craig Olson on 4/29/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// Query/operation level GraphQL error
public struct GraphQLOperationError: APIError, Equatable, Codable {
    let code: Int
    let message: String
    
    var title: String {
        return message
    }
}
