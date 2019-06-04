//
//  HostProtocol.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/4/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

public protocol HostProtocol {
    var baseURL: String { get }
    var token: String { get }
}
