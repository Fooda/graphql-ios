//
//  GraphQLJSONDecoder.swift
//  graphql_ios
//
//  Created by Blake Macnair on 4/4/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

internal class GraphQLJSONDecoder: JSONDecoder {
    var logger: GraphQLLogging?

    override init() {
        super.init()
        self.keyDecodingStrategy = .convertFromSnakeCase
        self.dateDecodingStrategy = .iso8601
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
