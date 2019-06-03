//
//  GraphQLClientProtocol.swift
//  iFooda
//
//  Created by Craig Olson on 4/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Alamofire
import enum Swift.Result

protocol GraphQLClientProtocol: ClientProtocol {
    func performOperation<T: GraphQLOperation, U: GraphQLPayload>(_ operation: T,
                                                                  parameters: GraphQLParameters?,
                                                                  headers: Headers?,
                                                                  completion: @escaping ((Result<U, Error>) -> Void))
}
