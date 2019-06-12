//
//  GrqphQLDeodable.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/7/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// The response to a single GraphQL operation
// We can get an error or some data 
public protocol GraphQLDecodable: Decodable {
    var error: GraphQLOperationError? { get }
}
