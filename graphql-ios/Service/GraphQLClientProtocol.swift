//
//  GraphQLClientProtocol.swift
//  graphql_ios
//
//  Created by Craig Olson on 4/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Alamofire
import enum Swift.Result

public protocol GraphQLClientProtocol {
    func performOperation<T: GraphQLOperation, U: GraphQLPayload>(_ operation: T,
                                                                  parameters: GraphQLParameters?,
                                                                  headers: [String: String]?,
                                                                  completion: @escaping ((Result<U, Error>) -> Void))
}
