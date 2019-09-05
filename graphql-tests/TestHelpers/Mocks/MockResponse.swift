//
//  MockResponse.swift
//  graphql-iosTests
//
//  Created by Jake Hergott on 6/19/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

#if os(iOS)
  @testable import graphql_ios
#else
  @testable import graphql_macos
#endif

struct MockResponse: GraphQLPayload {
    struct DecodableResult: GraphQLDecodable {
        var error: GraphQLOperationError?
        var text: String?
    }

    let result: DecodableResult
    var errors: [GraphQLNamedOperationError] {
        var errors = [GraphQLNamedOperationError]()
        if let error = result.error {
            errors.append(GraphQLNamedOperationError(name: "result", error: error))
        }
        return errors
    }
}
