//
//  FoodaJSONDecoder.swift
//  iFooda
//
//  Created by Blake Macnair on 4/4/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

// TODO: Move this to a different framework? REST? Decoding? 
public class FoodaJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        self.keyDecodingStrategy = .convertFromSnakeCase
    }

    func decodeObjectNotation<T>(_ type: T.Type, from obj: Any) throws -> T where T: Decodable {
        let reData = try JSONSerialization.data(withJSONObject: obj)
        do {
            return try self.decode(T.self, from: reData)
        } catch {
            // TODO
//            Logger.shared.unexpectedJson(type: String(describing: T.self), json: obj)
            throw error
        }
    }
}
