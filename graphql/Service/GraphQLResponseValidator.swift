//
//  GraphQLResponseValidator.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/5/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import Foundation

internal class GraphQLResponseValidator {
    func validateResponse(statusCode: Int, responseError: Error?) throws {
        switch statusCode {
        case 401, 403:
            throw GraphQLRemoteError.invalidCredentials
        case 500...:
            throw GraphQLRemoteError.serverError(statusCode: statusCode)
        case 0:
            if let urlError = responseError as? URLError {
                throw GraphQLRemoteError.networkError(urlError)
            } else if let genericError = responseError {
                throw genericError
            } else {
                throw GraphQLRemoteError.unknown
            }
        default:
            break
        }
    }
}
