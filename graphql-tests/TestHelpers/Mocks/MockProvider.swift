//
//  MockProvider.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql

class MockProvider: GraphQLProvider {
    var fullUrl: String
    var clientToken: String
    var sessionToken: String?

    init(fullUrl: String = "api.fooda.com/graphql",
         clientToken: String = "aaaaaaaaaaaa",
         sessionToken: String? = nil) {
        self.fullUrl = fullUrl
        self.clientToken = clientToken
        self.sessionToken = sessionToken
    }
}
