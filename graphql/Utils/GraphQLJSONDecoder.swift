//
//  GraphQLJSONDecoder.swift
// graphql
//
//  Created by Blake Macnair on 4/4/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Foundation

internal class GraphQLJSONDecoder: JSONDecoder {
    var logger: GraphQLLogging?

    override init() {
        super.init()
        self.keyDecodingStrategy = .convertFromSnakeCase
        if #available(iOS 10.0, *) {
            self.dateDecodingStrategy = .iso8601
        } else {
            self.dateDecodingStrategy = .custom { decoder -> Date in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                guard let date = DateFormatter.iso8601Formatter.date(from: dateString) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Couldn't convert the given string to a date")
                }
                return date
            }
        }
    }

    func decodeObjectNotation<T>(_ type: T.Type, from obj: Any) throws -> T where T: Decodable {
        let reData = try JSONSerialization.data(withJSONObject: obj)
        do {
            return try self.decode(T.self, from: reData)
        } catch {
            logger?.errorGraphQL("unexpected_json",
                                 params: [
                                    "type": String(describing: T.self),
                                    "json": obj
                ])

            throw error
        }
    }
}
