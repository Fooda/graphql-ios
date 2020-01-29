//
//  MockLogger.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

@testable import graphql_ios

class MockLogger: GraphQLLogging {
    struct Log {
        enum LogLevel {
            case info, error
        }
        let type: LogLevel
        let message: String
        let params: [String: Any]?
    }

    private(set) var logs = [Log]()

    func infoGraphQL(_ message: String, params: [String: Any]?) {
        let log = Log(type: .info, message: message, params: params)
        logs.append(log)
    }

    func errorGraphQL(_ message: String, params: [String: Any]?) {
        let log = Log(type: .error, message: message, params: params)
        logs.append(log)
    }

    func reset() {
        logs = []
    }
}
