//
//  MockRequest.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

enum MockRequest: GraphQLRequest {
    case authenticated(sessionToken: String)
    case anonymous(sessionToken: String?)

    var name: String { return "name" }
    var query: String { return "query" }
    var variables: [String: Any] { return ["key": "value"] }

    var authentication: GraphQLAuthentication {
        switch self {
        case let .authenticated(sessionToken):
            return .authenticated(sessionToken: sessionToken)
        case let .anonymous(sessionToken):
            return .anonymous(sessionToken: sessionToken)
        }
    }
}
