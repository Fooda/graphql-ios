//
//  MockRequest.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

enum MockRequest: GraphQLRequest {
    case authenticated
    case anonymous

    var name: String { return "name" }
    var query: String { return "query" }
    var variables: [String: Any] { return ["key": "value"] }

    var authentication: GraphQLAuthentication {
        switch self {
        case .anonymous:
            return .anonymous
        case .authenticated:
            return .authenticated
        }
    }
}
