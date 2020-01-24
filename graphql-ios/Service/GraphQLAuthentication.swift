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
