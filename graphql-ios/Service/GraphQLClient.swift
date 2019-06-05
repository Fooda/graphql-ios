//
//  GraphQLClient.swift
//  iFooda
//
//  Created by Craig Olson on 4/30/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

import Alamofire
import enum Swift.Result

public struct GraphQLClient: GraphQLClientProtocol {
    public static let shared = GraphQLClient()
    private let manager: Alamofire.SessionManager
    private let decoder: GraphQLJSONDecoder
    private let requestFormatter: GraphQLRequestFormatter
    private let responseValidator: GraphQLResponseValidator

    private init() {
        let configuration = URLSessionConfiguration.default
        manager = Alamofire.SessionManager(configuration: configuration)
        decoder = GraphQLJSONDecoder()
        requestFormatter = GraphQLRequestFormatter()
        responseValidator = GraphQLResponseValidator()
    }

    public func performOperation<T: GraphQLOperation, U: GraphQLPayload, V: GraphQLHost>(_ operation: T,
                                                                                          host: V,
                                                                                          parameters: GraphQLParameters? = nil,
                                                                                          headers: [String: String]? = nil,
                                                                                          completion: @escaping ((Result<U, Error>) -> Void)) {
        let requestBody = requestFormatter.requestBody(operation, parameters: parameters)
        request(operation: operation,
                host: host,
                method: .post,
                parameters: requestBody,
                headers: headers,
                completion: completion)
    }
}

// MARK: - Private Methods
private extension GraphQLClient {
    func request<T: GraphQLOperation, U: GraphQLPayload, V: GraphQLHost>(operation: T,
                                                                          host: V,
                                                                          method: HTTPMethod,
                                                                          parameters: Parameters? = nil,
                                                                          headers: [String: String]? = nil,
                                                                          completion: @escaping ((Result<U, Error>) -> Void)) {
        let requestId = UUID().uuidString
//        Logger.shared.log(logLevel: .info, message: "graphql_start", parameters: [
//            "url": url,
//            "requestId": requestId,
//            "type": operation.type.rawValue,
//            "name": operation.name
//            ])
        var updatedHeaders: [String: String]
        do {
            updatedHeaders = try requestHeaders(with: headers, clientToken: host.token, authentication: operation.authentication)
        } catch {
            completion(.failure(error))
//            Logger.shared.log(logLevel: .error, message: "graphql_invalid_header", parameters: [
//                "url": url,
//                "requestId": requestId,
//                "type": operation.type.rawValue,
//                "name": operation.name,
//                "error": error.localizedDescription
//                ])
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
                                    requestId: requestId,
                                    method: method,
                                    parameters: parameters,
                                    headers: headers,
                                    response: response,
                                    completion: completion)
        }
    }

    func handleResponse<T: GraphQLOperation, U: GraphQLPayload>(operation: T,
                                                                requestId: String,
                                                                method: HTTPMethod,
                                                                parameters: Parameters?,
                                                                headers: [String: String]?,
                                                                response: DataResponse<Any>,
                                                                completion: @escaping ((Result<U, Error>) -> Void)) {
        let statusCode = response.response?.statusCode ?? 0

//        Logger.shared.log(logLevel: .info, message: "graphql_complete", parameters: [
//            "url": url,
//            "requestId": requestId,
//            "status": statusCode,
//            "type": operation.type.rawValue,
//            "name": operation.name,
//            "variables": parameters?["variables"] ?? [:],
//            "timeline": ["latency": response.timeline.latency,
//                         "request": response.timeline.requestDuration,
//                         "parsing": response.timeline.serializationDuration,
//                         "total": response.timeline.totalDuration]
//            ])

        let data = response.data ?? Data()
        let rawJson = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]

        do {
            let data = response.data ?? Data()
            let apiResponse = try decoder.decode(GraphQLResponse<U>.self, from: data)

            try self.responseValidator.validateResponse(statusCode: statusCode, responseError: response.error, errors: apiResponse.errors ?? [])

            if let errors = apiResponse.errors, !errors.isEmpty {
                // handle base error, 200 status code
                throw GraphQLRemoteError.requestError(statusCode: statusCode, errors: errors)
            }
            guard let result = apiResponse.data else {
                throw GraphQLRemoteError.unexpectedJSON
            }

            logOperationErrors(operation: operation, requestId: requestId, parameters: parameters, result: result, rawJson: rawJson, response: response)
            try result.validateResponse()

            completion(.success(result))
        } catch {
//            Logger.shared.log(logLevel: .error, message: "graphql_failure", parameters: [
//                "url": url,
//                "requestId": requestId,
//                "status": statusCode,
//                "type": operation.type.rawValue,
//                "name": operation.name,
//                "variables": parameters?["variables"] ?? [:],
//                "timeline": ["latency": response.timeline.latency,
//                             "request": response.timeline.requestDuration,
//                             "parsing": response.timeline.serializationDuration,
//                             "total": response.timeline.totalDuration],
//                "response": rawJson ?? [:],
//                "error": (error as? DebugError)?.debugDescription ?? error.localizedDescription
//                ])
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
            // TODO: How to handle invalid session token
            //            guard let sessionToken = UserManager.sessionToken else {
            //                throw RemoteResourceError.invalidCredentials
            //            }
            //            headers["X-SessionToken"] = sessionToken
            break
        case .anonymous:
            //            if let sessionToken = UserManager.sessionToken {
            //                headers["X-SessionToken"] = sessionToken
            //            }
            break
        }
        return headers
    }

    func logOperationErrors<T: GraphQLOperation, U: GraphQLPayload>(operation: T,
                                                                    requestId: String,
                                                                    parameters: Parameters?,
                                                                    result: U,
                                                                    rawJson: [String: Any]?,
                                                                    response: DataResponse<Any>) {
        for error in result.errors {
//            Logger.shared.log(logLevel: .error, message: "graphql_operation_error", parameters: [
//                "url": url,
//                "requestId": requestId,
//                "status": response.response?.statusCode ?? 0,
//                "type": operation.type.rawValue,
//                "name": operation.name,
//                "variables": parameters?["variables"] ?? [:],
//                "response": rawJson ?? [:],
//                "operation_error": error.dictionary
//                ])
        }
    }
}
