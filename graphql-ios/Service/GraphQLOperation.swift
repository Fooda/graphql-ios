//
//  GraphQLOperation.swift
//  iFooda
//
//  Created by Craig Olson on 5/3/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

protocol GraphQLOperation: GraphQLNode {
    var type: GraphQLOperationType { get }
    var authentication: Authentication { get }
    var name: String { get }
}
