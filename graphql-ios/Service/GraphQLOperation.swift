//
//  GraphQLOperation.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/3/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public protocol GraphQLOperation: GraphQLNode {
    var type: GraphQLOperationType { get }
    var authentication: GraphQLAuthentication { get }
    var name: String { get }
}
