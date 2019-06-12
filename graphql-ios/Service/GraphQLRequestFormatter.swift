//
//  GraphQLRequestFormatter.swift
//  graphql_ios
//
//  Created by Craig Olson on 4/25/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

internal struct GraphQLRequestFormatter {
    func requestBody<T: GraphQLOperation>(_ operation: T, parameters: GraphQLParameters?) -> [String: Any] {
        var json = [String: Any]()
        json["query"] = operation.description
        json["variables"] = parameters?.dictionary
        return json
    }
}
