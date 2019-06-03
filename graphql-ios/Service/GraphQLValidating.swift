//
//  GraphQLValidating.swift
//  iFooda
//
//  Created by Craig Olson on 5/7/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public protocol GraphQLValidating {
    func validateResponse() throws
}

extension GraphQLValidating where Self: GraphQLPayload {
    func validateResponse() throws {
        guard let statusCode = errors.first?.error.code else { return }
        switch statusCode {
        case 401, 403:
            let invalidCredentials = RemoteResourceError.invalidCredentials
            NotificationCenter.default.post(name: Notification.Name.UserUnauthorized,
                                            object: nil,
                                            userInfo: [Constants.NotificationKeys.remoteResourceError: invalidCredentials])
            throw invalidCredentials
        case 503:
            let siteMaintenance = RemoteResourceError.siteMaintenance
            NotificationCenter.default.post(name: Notification.Name.SiteMaintenance,
                                            object: nil,
                                            userInfo: [Constants.NotificationKeys.remoteResourceError: siteMaintenance])
            throw siteMaintenance
        case 400...:
            throw RemoteResourceError.graphQLError(errors: errors)
        default:
            break
        }
    }
}
