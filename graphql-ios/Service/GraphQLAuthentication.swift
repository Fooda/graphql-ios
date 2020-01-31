//
//  GraphQLAuthentication.swift
//  graphql_ios
//
//  Created by Nejc Vivod on 29/01/2018.
//  Copyright © 2018 Fooda, Inc. All rights reserved.
//

public enum GraphQLAuthentication {
    case authenticated(sessionToken: String)
    case anonymous(sessionToken: String?)
}

extension GraphQLAuthentication: Equatable {
    public static func == (lhs: GraphQLAuthentication, rhs: GraphQLAuthentication) -> Bool {
        switch (lhs, rhs) {
        case (.authenticated(let lhsSessionToken), .authenticated(let rhsSessionToken)):
            return lhsSessionToken == rhsSessionToken
        case (.anonymous(let lhsSessionToken), .anonymous(let rhsSessionToken)):
            return lhsSessionToken == rhsSessionToken
        default:
            return false
        }
    }
}
