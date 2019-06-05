//
//  ClientProtocol.swift
//  iFooda
//
//  Created by Craig Olson on 4/26/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public protocol ClientProtocol {}

extension ClientProtocol {
    public func validateResponse(statusCode: Int, responseError: Error?, errors: [GraphQLError]) throws {
        switch statusCode {
        case 401, 403:
            throw RemoteGraphQLError.invalidCredentials
        case 503:
            let siteMaintenance = RemoteGraphQLError.siteMaintenance
            NotificationCenter.default.post(name: Notification.Name.SiteMaintenance,
                                            object: nil,
                                            userInfo: ["remote_resource_error": siteMaintenance])
            throw siteMaintenance
        case 500...:
            throw RemoteGraphQLError.serverError(statusCode: statusCode, errors: errors)
        case 400..<500:
            throw RemoteGraphQLError.requestError(statusCode: statusCode, errors: errors)
        case 0:
            if let urlError = responseError as? URLError {
                throw RemoteGraphQLError.networkError(urlError)
            } else if let genericError = responseError {
                throw genericError
            } else {
                throw RemoteGraphQLError.unknown
            }
        default:
            break
        }
    }

    public func requestHeaders(with customHeader: [String: String]?, clientToken: String?, authentication: Authentication) throws -> [String: String] {
        var headers: [String: String] = ["X-AppPlatform": "iOS",
                                         "X-AppVersion": Bundle.appVersion,
                                         "X-AppBundle": Bundle.bundleId ?? "/"]

        // custom headers
        if let customHeader = customHeader {
            for (key, value) in customHeader {
                headers[key] = value
            }
        }

        // client token
        if let clientToken = clientToken {
            headers["X-ClientToken"] = clientToken
        }

        // session token
        switch authentication {
        case .authenticated:
            // TODO: How to handle invalid session token
//            guard let sessionToken = UserManager.sessionToken else {
//                throw RemoteResourceError.invalidCredentials
//            }
//            headers["X-SessionToken"] = sessionToken
            break
        case .anonymous:
//            if let sessionToken = UserManager.sessionToken {
//                headers["X-SessionToken"] = sessionToken
//            }
            break
        }
        return headers
    }
}
