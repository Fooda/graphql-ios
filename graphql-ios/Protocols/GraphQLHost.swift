//
//  GraphQLHost.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/4/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public protocol GraphQLHost {
    var baseURL: String { get }
    var token: String { get }
}
