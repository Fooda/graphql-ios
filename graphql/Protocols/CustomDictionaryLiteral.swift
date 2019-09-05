//
//  CustomDictionaryLiteral.swift
//  graphql_ios
//
//  Created by Craig Olson on 5/17/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Foundation

internal protocol CustomDictionaryLiteral {
    var dictionary: [String: Any] { get }
}

extension CustomDictionaryLiteral where Self: Encodable {
    internal var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
