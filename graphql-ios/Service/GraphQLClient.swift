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
    private let decoder: FoodaJSONDecoder
    private let requestFormatter: GraphQLRequestFormatter

    private init() {
        let configuration = URLSessionConfiguration.default
        manager = Alamofire.SessionManager(configuration: configuration)
        decoder = FoodaJSONDecoder()
        requestFormatter = GraphQLRequestFormatter()
    }

    public func performOperation<T: GraphQLOperation, U: GraphQLPayload, V: HostProtocol>(_ operation: T,
                                                                                          host: V,
                                                                                          parameters: GraphQLParameters? = nil,
                                                                                          headers: Headers? = nil,
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
    func request<T: GraphQLOperation, U: GraphQLPayload, V: HostProtocol>(operation: T,
                                                                          host: V,
                                                                          method: HTTPMethod,
                                                                          parameters: Parameters? = nil,
                                                                          headers: Headers? = nil,
                                                                          completion: @escaping ((Result<U, Error>) -> Void)) {
        let requestId = UUID().uuidString
//        Logger.shared.log(logLevel: .info, message: "graphql_start", parameters: [
//            "url": url,
//            "requestId": requestId,
//            "type": operation.type.rawValue,
//            "name": operation.name
//            ])
        var updatedHeaders: Headers
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
                                                                headers: Headers?,
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
        let rawJson = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? ObjectNotation

        do {
            let data = response.data ?? Data()
            let apiResponse = try decoder.decode(GraphQLResponse<U>.self, from: data)

            try self.validateResponse(statusCode: statusCode, responseError: response.error, errors: apiResponse.errors ?? [])

            if let errors = apiResponse.errors, !errors.isEmpty {
                // handle base error, 200 status code
                throw RemoteGraphQLError.requestError(statusCode: statusCode, errors: errors)
            }
            guard let result = apiResponse.data else {
                throw MappingError.unexpectedJSON
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

    func logOperationErrors<T: GraphQLOperation, U: GraphQLPayload>(operation: T,
                                                                    requestId: String,
                                                                    parameters: Parameters?,
                                                                    result: U,
                                                                    rawJson: ObjectNotation?,
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
