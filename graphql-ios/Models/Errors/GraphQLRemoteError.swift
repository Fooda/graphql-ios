//
//  GraphQLRemoteError.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/5/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public enum GraphQLRemoteError: LocalizedError {
    case serverError(httpStatusCode: Int)
    case protocolError(httpStatusCode: Int, errors: [GraphQLProtocolError])
    case networkError(URLError)
    case unexpectedJSON(httpStatusCode: Int)
    case unknown

    public var errorDescription: String? {
        let defaultMessage = "We’re having trouble connecting to Fooda, try again in a few minutes. If the problem persists, please contact support. We apologize for this inconvenience.".localized()

        switch self {
        case let .protocolError(_, errors: errors):
            return errors.first?.message ?? defaultMessage
        case let .networkError(urlError):
            return urlError.localizedDescription
        case .serverError,
             .unexpectedJSON,
             .unknown:
            return defaultMessage
        }
    }

    var debugDescription: String {
        switch self {
        case let .serverError(httpStatusCode):
            return "server_\(httpStatusCode)"
        case .protocolError:
            return "protocol_error"
        case .unknown:
            return "unknown_error"
        case .unexpectedJSON:
            return "unexpected_json"
        case let .networkError(urlError):
            return "network_\((urlError as NSError).debugDescription)"
        }
    }

    var httpStatusCode: Int {
        switch self {
        case let .serverError(httpStatusCode),
             let .protocolError(httpStatusCode, _),
             let .unexpectedJSON(httpStatusCode):
            return httpStatusCode
        case .networkError,
             .unknown:
            return 0
        }
    }
}
