//
//  GraphQLClient.swift
//  iFooda
//
//  Created by Craig Olson on 4/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Alamofire
import enum Swift.Result

public class GraphQLClient: GraphQLClientProtocol {
    public static let shared = GraphQLClient()
    private let manager: Alamofire.SessionManager
    private let decoder: GraphQLJSONDecoder
    private let requestFormatter: GraphQLRequestFormatter
    private let responseValidator: GraphQLResponseValidator

    // MARK: - Configurable properties
    private var logger: GraphQLLogging?
    private var provider: GraphQLProvider?

    // MARK: - Initializers
    private init() {
        let configuration = URLSessionConfiguration.default
        manager = Alamofire.SessionManager(configuration: configuration)
        decoder = GraphQLJSONDecoder()
        requestFormatter = GraphQLRequestFormatter()
        responseValidator = GraphQLResponseValidator()
    }

    public func configure(logger: GraphQLLogging, provider: GraphQLProvider) {
        self.logger = logger
        decoder.logger = logger
        self.provider = provider
    }

    public func performOperation<T: GraphQLOperation, U: GraphQLPayload>(_ operation: T,
                                                                         parameters: GraphQLParameters? = nil,
                                                                         headers: [String: String]? = nil,
                                                                         completion: @escaping ((Result<U, Error>) -> Void)) {
        let requestBody = requestFormatter.requestBody(operation, parameters: parameters)
        request(operation: operation,
                method: .post,
                parameters: requestBody,
                headers: headers,
                completion: completion)
    }
}

// MARK: - Private Methods
private extension GraphQLClient {
    func request<T: GraphQLOperation, U: GraphQLPayload>(operation: T,
                                                         method: HTTPMethod,
                                                         parameters: Parameters? = nil,
                                                         headers: [String: String]? = nil,
                                                         completion: @escaping ((Result<U, Error>) -> Void)) {
        guard let host = provider?.host else {
            completion(.failure(GraphQLRemoteError.undefinedHost))
            return
        }
        let url = "\(host.baseURL)/graphql"
        let requestId = UUID().uuidString
        logger?.infoGraphQL("graphql_start",
                            params: [
                                "url": url,
                                "requestId": requestId,
                                "type": operation.type.rawValue,
                                "name": operation.name
            ])
        var updatedHeaders: [String: String]
        do {
            updatedHeaders = try requestHeaders(with: headers, clientToken: host.token, authentication: operation.authentication)
        } catch {
            completion(.failure(error))
            logger?.errorGraphQL("graphql_invalid_header",
                                 params: [
                                    "url": url,
                                    "requestId": requestId,
                                    "type": operation.type.rawValue,
                                    "name": operation.name,
                                    "error": error.localizedDescription
                ])
            return
        }

        manager.request("\(host.baseURL)/graphql",
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: updatedHeaders)
            .validate()
            .responseJSON { response in
                self.handleResponse(operation: operation,
                                    host: host,
                                    requestId: requestId,
                                    method: method,
                                    parameters: parameters,
                                    headers: headers,
                                    response: response,
                                    completion: completion)
        }
    }

    func handleResponse<T: GraphQLOperation, U: GraphQLPayload>(operation: T,
                                                                host: GraphQLHost,
                                                                requestId: String,
                                                                method: HTTPMethod,
                                                                parameters: Parameters?,
                                                                headers: [String: String]?,
                                                                response: DataResponse<Any>,
                                                                completion: @escaping ((Result<U, Error>) -> Void)) {
        let statusCode = response.response?.statusCode ?? 0
        let url = "\(host.baseURL)/graphql"

        logger?.infoGraphQL("graphql_complete", params: [
            "url": url,
            "requestId": requestId,
            "status": statusCode,
            "type": operation.type.rawValue,
            "name": operation.name,
            "variables": parameters?["variables"] ?? [:],
            "timeline": ["latency": response.timeline.latency,
                         "request": response.timeline.requestDuration,
                         "parsing": response.timeline.serializationDuration,
                         "total": response.timeline.totalDuration]
            ])

        let data = response.data ?? Data()
        // rawJson is for logging purposes only
        let rawJson = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]

        do {
            try self.responseValidator.validateResponse(statusCode: statusCode, responseError: response.error)

            let apiResponse = try decoder.decode(GraphQLResponse<U>.self, from: data)

            if let errors = apiResponse.errors, !errors.isEmpty {
                // handle base error, 200 status code
                throw GraphQLRemoteError.protocolError(statusCode: statusCode, errors: errors)
            }
            guard let result = apiResponse.data else {
                throw GraphQLRemoteError.unexpectedJSON
            }

            logOperationErrors(operation: operation, host: host, requestId: requestId, parameters: parameters, result: result, rawJson: rawJson, response: response)
            try result.validateResponse()

            completion(.success(result))
        } catch {
            logger?.errorGraphQL("graphql_failure",
                                 params: [
                                    "url": url,
                                    "requestId": requestId,
                                    "status": statusCode,
                                    "type": operation.type.rawValue,
                                    "name": operation.name,
                                    "variables": parameters?["variables"] ?? [:],
                                    "timeline": ["latency": response.timeline.latency,
                                                 "request": response.timeline.requestDuration,
                                                 "parsing": response.timeline.serializationDuration,
                                                 "total": response.timeline.totalDuration],
                                    "response": rawJson ?? [:],
                                    "error": (error as? GraphQLRemoteError)?.debugDescription ?? error.localizedDescription
                ])
            completion(.failure(error))
        }
    }

    func requestHeaders(with customHeader: [String: String]?, clientToken: String?, authentication: GraphQLAuthentication) throws -> [String: String] {
        var headers: [String: String] = ["X-AppPlatform": "iOS",
                                         "X-AppVersion": Bundle.appVersion,
                                         "X-AppBundle": Bundle.bundleId ?? "/"]

        // custom headers
        if let customHeader = customHeader {
            for (key, value) in customHeader {
                headers[key] = value
            }
        }

        // client token
        if let clientToken = clientToken {
            headers["X-ClientToken"] = clientToken
        }

        // session token
        switch authentication {
        case .authenticated:
            guard let sessionToken = provider?.sessionToken else {
                throw GraphQLRemoteError.invalidCredentials
            }
            headers["X-SessionToken"] = sessionToken
        case .anonymous:
            if let sessionToken = provider?.sessionToken {
                headers["X-SessionToken"] = sessionToken
            }
        }
        return headers
    }

    func logOperationErrors<T: GraphQLOperation, U: GraphQLPayload>(operation: T,
                                                                    host: GraphQLHost,
                                                                    requestId: String,
                                                                    parameters: Parameters?,
                                                                    result: U,
                                                                    rawJson: [String: Any]?,
                                                                    response: DataResponse<Any>) {
        let url = "\(host.baseURL)/graphql"
        for error in result.errors {
            logger?.errorGraphQL("graphql_operation_error",
                                 params: [
                                    "url": url,
                                    "requestId": requestId,
                                    "status": response.response?.statusCode ?? 0,
                                    "type": operation.type.rawValue,
                                    "name": operation.name,
                                    "variables": parameters?["variables"] ?? [:],
                                    "response": rawJson ?? [:],
                                    "operation_error": error.dictionary
                ])
        }
    }
}
