//
//  MockProvider.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

class MockProvider: GraphQLProvider {
    var host: GraphQLHost = MockHost()
    var sessionToken: String?

    init(host: GraphQLHost = MockHost(), sessionToken: String? = nil) {
        self.host = host
        self.sessionToken = sessionToken
    }
}
