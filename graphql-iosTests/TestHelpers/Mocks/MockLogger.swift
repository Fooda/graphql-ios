//
//  MockLogger.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

struct MockLogger: GraphQLLogging {
    func infoGraphQL(_ message: String, params: [String : Any]?) {}
    func errorGraphQL(_ message: String, params: [String : Any]?) {}
}
