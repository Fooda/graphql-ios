//
//  GraphQLProvider.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/6/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public protocol GraphQLProvider {
    static var host: GraphQLHost { get }
    static var sessionToken: String? { get }
}
