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
    func performOperation<T: Decodable>(request: GraphQLRequest,
                                        headers: [String: String]?,
                                        completion: @escaping ((Result<T, Error>) -> Void))
}
