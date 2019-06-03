//
//  GraphQLParameters.swift
//  iFooda
//
//  Created by Craig Olson on 5/16/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

enum GraphQLParameters {
    case base([String: Any])
    case input([String: Any])

    var dictionary: [String: Any] {
        switch self {
        case let .base(values):
            return values
        case let .input(values):
            return ["input": values]
        }
    }
}
