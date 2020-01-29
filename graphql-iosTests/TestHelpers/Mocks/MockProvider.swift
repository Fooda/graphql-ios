//
//  MockProvider.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

class MockProvider: GraphQLProvider {
    var fullUrl: String
    var clientToken: String

    init(fullUrl: String = "api.fooda.com/graphql",
         clientToken: String = "aaaaaaaaaaaa") {
        self.fullUrl = fullUrl
        self.clientToken = clientToken
    }
}
