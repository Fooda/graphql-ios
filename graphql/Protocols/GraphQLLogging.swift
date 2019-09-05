//
//  GraphQLLogging.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/6/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public protocol GraphQLLogging {
    func infoGraphQL(_ message: String, params: [String: Any]?)
    func errorGraphQL(_ message: String, params: [String: Any]?)
}
