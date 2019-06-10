//
//  MockHost.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

struct MockHost: GraphQLHost {
    var baseURL: String = "api.fooda.com"
    var token: String = "aaaaaaaaaaaaaaaaaaaaaaaaa"
}
