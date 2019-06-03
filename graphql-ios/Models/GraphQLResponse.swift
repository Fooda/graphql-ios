//
//  GraphQLResponse.swift
//  iFooda
//
//  Created by Craig Olson on 4/29/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// GraphQL object directly inside response body
// Can get data or a list of errors if the request
// was improperly formatted 
public struct GraphQLResponse<T: GraphQLPayload>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}
