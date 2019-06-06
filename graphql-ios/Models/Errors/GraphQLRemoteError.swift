//
//  GraphQLRemoteError.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/5/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public enum GraphQLRemoteError: LocalizedError {
    case invalidCredentials // 401 or 403
    case siteMaintenance // 503
    case serverError(statusCode: Int, errors: [GraphQLError])
    case requestError(statusCode: Int, errors: [GraphQLError])
    case networkError(URLError)
    case unexpectedJSON
    case operationErrors(_ errors: [GraphQLNamedOperationError])
    case undefinedHost
    case unknown

    public var errorDescription: String? {
        let defaultMessage = "We’re having trouble connecting to Fooda, try again in a few minutes. If the problem persists, please contact support. We apologize for this inconvenience.".localized()

        switch self {
        case .invalidCredentials:
            return "Invalid credentials".localized()
        case .siteMaintenance:
            return "Sorry for the inconvenience but we're performing scheduled maintenance at the moment. If you need to you can always contact us at info@fooda.com. We'll be back online shortly!".localized()
        case let .serverError(_, errors), let .requestError(_, errors):
            return errors.first?.message ?? defaultMessage
        case let .operationErrors(errors):
            return errors.first?.error.message ?? defaultMessage
        case let .networkError(urlError):
            return urlError.localizedDescription
        case .unexpectedJSON, .unknown, .undefinedHost:
            return defaultMessage
        }
    }

    var debugDescription: String {
        switch self {
        case .invalidCredentials:
            return "invalid_credentials"
        case .siteMaintenance:
            return "site_maintenance"
        case let .serverError(statusCode, _):
            return "server_\(statusCode)"
        case let .requestError(statusCode, _):
            return "request_\(statusCode)"
        case .operationErrors:
            return "operation_error"
        case .unknown:
            return "unknown_error"
        case .unexpectedJSON:
            return "unexpected_json"
        case .undefinedHost:
            return "undefined_host"
        case let .networkError(urlError):
            return "network_\((urlError as NSError).debugDescription)"
        }
    }
}
