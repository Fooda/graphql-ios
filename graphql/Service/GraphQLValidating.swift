//
//  GraphQLValidating.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/7/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public protocol GraphQLValidating {
    func validateResponse() throws
}

extension GraphQLValidating where Self: GraphQLPayload {
    public func validateResponse() throws {
        guard let statusCode = errors.first?.error.code else { return }
        switch statusCode {
        case 401, 403:
            let invalidCredentials = GraphQLRemoteError.invalidCredentials
            NotificationCenter.default.post(name: Notification.Name.UserUnauthorized,
                                            object: nil,
                                            userInfo: ["graphql_resource_error": invalidCredentials])
            throw invalidCredentials
        case 400...:
            throw GraphQLRemoteError.operationErrors(errors)
        default:
            break
        }
    }
}
