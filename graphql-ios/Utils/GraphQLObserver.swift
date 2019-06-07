//
//  GraphQLObserver.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/7/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import Foundation

public protocol GraphQLObserverDelegate: AnyObject {
    func didReceiveInvalidCredentials()
    func didReceiveSiteMaintenance()
}

public final class GraphQLObserver {
    weak var delegate: GraphQLObserverDelegate?
    private let notificationCenter = NotificationCenter.default

    public init() {
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveInvalidCredentials),
                                       name: Notification.Name.UserUnauthorized,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveSiteMaintenance),
                                       name: Notification.Name.SiteMaintenance,
                                       object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - Private methods
private extension GraphQLObserver {
    @objc func didReceiveInvalidCredentials() {
        delegate?.didReceiveInvalidCredentials()
    }

    @objc func didReceiveSiteMaintenance() {
        delegate?.didReceiveSiteMaintenance()
    }
}
