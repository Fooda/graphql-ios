//
//  GraphQLProtocolError.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/9/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

/**
 `GraphQLProtocolError` is an error that the server responds with when the server cannot understand the request.
 The server will respond with an array of `errors`.

 ## Examples
 - The query has field(s) that do not exist.
 - The operation does not provide the required inputs.
 */
public struct GraphQLProtocolError: Decodable {
    let message: String
}
