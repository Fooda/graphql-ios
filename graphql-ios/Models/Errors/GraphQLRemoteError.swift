//
//  GraphQLRemoteError.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/5/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public enum GraphQLRemoteError: LocalizedError {
    case invalidCredentials
    case serverError(statusCode: Int)
    case protocolError(statusCode: Int, errors: [GraphQLError])
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
        case let .protocolError(_, errors: errors):
            return errors.first?.message ?? defaultMessage
        case let .operationErrors(errors):
            return errors.first?.error.message ?? defaultMessage
        case let .networkError(urlError):
            return urlError.localizedDescription
        case .serverError, .unexpectedJSON, .unknown, .undefinedHost:
            return defaultMessage
        }
    }

    var debugDescription: String {
        switch self {
        case .invalidCredentials:
            return "invalid_credentials"
        case let .serverError(statusCode):
            return "server_\(statusCode)"
        case .protocolError:
            return "protocol_error"
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
