//
//  RemoteResourceError.swift
//  iFooda
//
//  Created by Jake Hergott on 8/30/17.
//  Copyright © 2017 Fooda, Inc. All rights reserved.
//

import Foundation

public enum RemoteResourceError: DebugError {
    case noInternetConnection
    case invalidCredentials // A 401 or 403 represents invalid credentials
    case invalidRequest(message: String?)
    case siteMaintenance // A 503 represents the site is under maintenance.
    case serverError(statusCode: Int, errors: [APIError])
    case requestError(statusCode: Int, errors: [APIError])
    case graphQLError(errors: [GraphQLNamedOperationError])
    case unexpectedJSON
    case unknownError
    case generic(Error)
    /// represents a network error with no status code that can be determined
    case network(URLError)

    public var errorDescription: String? {
        let defaultMessage = "We’re having trouble connecting to Fooda, try again in a few minutes. If the problem persists, please contact support. We apologize for this inconvenience.".localized()

        switch self {
        case .noInternetConnection:
            return "Connect to the internet".localized()
        case .invalidCredentials:
            return "Invalid credentials".localized()
        case let .invalidRequest(message):
            return message ?? defaultMessage
        case .siteMaintenance:
            return "Sorry for the inconvenience but we're performing scheduled maintenance at the moment. If you need to you can always contact us at info@fooda.com. We'll be back online shortly!".localized()
        case let .serverError(_, errors):
            return errors.first?.title ?? defaultMessage
        case let .requestError(_, errors):
            return errors.first?.title ?? defaultMessage
        case let .graphQLError(errors):
            return errors.first?.error.message ?? defaultMessage
        case .unknownError, .unexpectedJSON:
            return defaultMessage
        case let .generic(error):
            return error.localizedDescription
        case let .network(urlError):
            return urlError.localizedDescription
        }
    }

    var debugDescription: String {
        switch self {
        case .noInternetConnection:
            return "no_internet_connection"
        case .invalidCredentials:
            return "invalid_credentials"
        case let .invalidRequest(message):
            return "invalid_request_\(message ?? "/")"
        case .siteMaintenance:
            return "site_maintenance"
        case let .serverError(statusCode, _):
            return "server_\(statusCode)"
        case let .requestError(statusCode, _):
            return "request_\(statusCode)"
        case .graphQLError:
            return "graph_ql"
        case .unknownError:
            return "unknown_error"
        case .unexpectedJSON:
            return "unexpected_json"
        case let .generic(error):
            return "generic_\(error.localizedDescription)"
        case let .network(urlError):
            return "network_\((urlError as NSError).debugDescription)"
        }
    }
}
