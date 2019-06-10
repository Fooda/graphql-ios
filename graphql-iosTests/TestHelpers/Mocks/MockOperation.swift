//
//  MockOperation.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

enum MockOperation: GraphQLOperation {
    case authenticated
    case anonymous

    var type: GraphQLOperationType { return .query }
    var name: String { return "query" }
    var description: String { return "" }

    var authentication: GraphQLAuthentication {
        switch self {
        case .anonymous:
            return .anonymous
        case .authenticated:
            return .authenticated
        }
    }
}
