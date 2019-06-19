//
//  GraphQLRequest.swift
//  graphql-ios
//
//  Created by Jake Hergott on 6/19/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import Foundation

public protocol GraphQLRequest {
    var query: String { get }
    var variables: [String: Any] { get }
    var authentication: GraphQLAuthentication { get }
    var name: String { get }
}
