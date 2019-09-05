//
//  MockLogger.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

#if os(iOS)
  @testable import graphql_ios
#else
  @testable import graphql_macos
#endif

struct MockLogger: GraphQLLogging {
    func infoGraphQL(_ message: String, params: [String : Any]?) {}
    func errorGraphQL(_ message: String, params: [String : Any]?) {}
}
