//
//  GraphQLResponseValidator.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/5/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

internal class GraphQLResponseValidator {
    func validateResponse(statusCode: Int, responseError: Error?) throws {
        switch statusCode {
        case 401, 403:
            throw GraphQLRemoteError.invalidCredentials
        case 503:
            let siteMaintenance = GraphQLRemoteError.siteMaintenance
            NotificationCenter.default.post(name: Notification.Name.SiteMaintenance,
                                            object: nil,
                                            userInfo: ["remote_resource_error": siteMaintenance])
            throw siteMaintenance
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
