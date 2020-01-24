//
//  GraphQLProvider.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/6/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public protocol GraphQLProvider {
    var fullUrl: String { get }
    var clientToken: String { get }
}
