//
//  GraphQLClientProtocol.swift
//  iFooda
//
//  Created by Craig Olson on 4/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Alamofire
import enum Swift.Result

public protocol GraphQLClientProtocol {
    func performOperation<T: GraphQLOperation, U: GraphQLPayload, V: GraphQLHost>(_ operation: T,
                                                                                   host: V,
                                                                                   parameters: GraphQLParameters?,
                                                                                   headers: [String: String]?,
                                                                                   completion: @escaping ((Result<U, Error>) -> Void))
}
