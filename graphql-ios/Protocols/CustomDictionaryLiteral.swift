//
//  CustomDictionaryLiteral.swift
//  iFooda
//
//  Created by Craig Olson on 5/17/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

public protocol CustomDictionaryLiteral {
    var dictionary: [String: Any] { get }
}

extension CustomDictionaryLiteral where Self: Encodable {
    public var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
