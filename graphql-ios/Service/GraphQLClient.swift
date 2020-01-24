//
//  GraphQLClient.swift
//  graphql_ios
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

    // MARK: - Configurable properties
    private var logger: GraphQLLogging?
    private var provider: GraphQLProvider?

    // MARK: - Initializers
    private init() {
        let configuration = URLSessionConfiguration.default
        manager = Alamofire.SessionManager(configuration: configuration)
        decoder = GraphQLJSONDecoder()
    }

    public func configure(logger: GraphQLLogging?, provider: GraphQLProvider) {
        self.logger = logger
        decoder.logger = logger
        self.provider = provider
    }

    public func performOperation<T: GraphQLPayload>(request: GraphQLRequest,
                                                    headers: [String: String]? = nil,
                                                    completion: @escaping ((Result<T, Error>) -> Void)) {
        self.request(request: request,
                     method: .post,
                     headers: headers,
                     completion: completion)
    }
}

// MARK: - Private Methods
private extension GraphQLClient {
    func request<T: GraphQLPayload>(request: GraphQLRequest,
                                    method: HTTPMethod,
                                    headers: [String: String]? = nil,
                                    completion: @escaping ((Result<T, Error>) -> Void)) {
        guard let provider = provider else {
            completion(.failure(GraphQLRemoteError.undefinedHost))
            return
        }

        let url = provider.fullUrl
        let requestId = UUID().uuidString
        logger?.infoGraphQL("graphql_start",
                            params: [
                                "url": url,
                                "requestId": requestId,
                                "name": request.name
            ])
        var updatedHeaders: [String: String]
        do {
            updatedHeaders = try requestHeaders(with: headers,
                                                clientToken: provider.clientToken,
                                                authentication: request.authentication)
        } catch {
            completion(.failure(error))
            logger?.errorGraphQL("graphql_invalid_header",
                                 params: [
                                    "url": url,
                                    "requestId": requestId,
                                    "name": request.name,
                                    "error": error.localizedDescription
                ])
            return
        }

        var parameters: [String: Any] = ["query": request.query]
        if !request.variables.isEmpty {
            parameters["variables"] = request.variables
        }
        manager.request(url,
                        method: method,
                        parameters: parameters,
                        encoding: JSONEncoding.default,
                        headers: updatedHeaders)
            .validate()
            .responseJSON { response in
                self.handleResponse(request: request,
                                    url: url,
                                    requestId: requestId,
                                    method: method,
                                    parameters: parameters,
                                    headers: headers,
                                    response: response,
                                    completion: completion)
        }
    }

    func handleResponse<T: GraphQLPayload>(request: GraphQLRequest,
                                           url: String,
                                           requestId: String,
                                           method: HTTPMethod,
                                           parameters: Parameters?,
                                           headers: [String: String]?,
                                           response: DataResponse<Any>,
                                           completion: @escaping ((Result<T, Error>) -> Void)) {
        let statusCode = response.response?.statusCode ?? 0

        logger?.infoGraphQL("graphql_complete", params: [
            "url": url,
            "requestId": requestId,
            "status": statusCode,
            "name": request.name,
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
            try self.validateResponse(httpStatusCode: statusCode, responseError: response.error)

            let apiResponse = try decoder.decode(GraphQLResponse<T>.self, from: data)

            if let errors = apiResponse.errors, !errors.isEmpty {
                // handle base error, 200 status code
                throw GraphQLRemoteError.protocolError(statusCode: statusCode, errors: errors)
            }
            guard let result = apiResponse.data else {
                throw GraphQLRemoteError.unexpectedJSON
            }

            logOperationErrors(request: request, url: url, requestId: requestId, parameters: parameters, result: result, rawJson: rawJson, response: response)

            completion(.success(result))
        } catch {
            logger?.errorGraphQL("graphql_failure",
                                 params: [
                                    "url": url,
                                    "requestId": requestId,
                                    "status": statusCode,
                                    "name": request.name,
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
        case let .authenticated(sessionToken):
            headers["X-SessionToken"] = sessionToken
        case let .anonymous(sessionToken):
            if let sessionToken = sessionToken {
                headers["X-SessionToken"] = sessionToken
            }
        }
        return headers
    }

    func validateResponse(httpStatusCode: Int, responseError: Error?) throws {
        switch httpStatusCode {
        case 500...:
            throw GraphQLRemoteError.serverError(statusCode: httpStatusCode)
        case 0:
            if let urlError = responseError as? URLError {
                throw GraphQLRemoteError.networkError(urlError)
            } else if let genericError = responseError {
                throw genericError
            } else {
                throw GraphQLRemoteError.unknown
            }
        default:
            break
        }
    }

    func logOperationErrors<T: GraphQLPayload>(request: GraphQLRequest,
                                               url: String,
                                               requestId: String,
                                               parameters: Parameters?,
                                               result: T,
                                               rawJson: [String: Any]?,
                                               response: DataResponse<Any>) {
        for error in result.errors {
            logger?.errorGraphQL("graphql_operation_error",
                                 params: [
                                    "url": url,
                                    "requestId": requestId,
                                    "status": response.response?.statusCode ?? 0,
                                    "name": request.name,
                                    "variables": parameters?["variables"] ?? [:],
                                    "response": rawJson ?? [:],
                                    "operation_error_code": error.code,
                                    "operation_error_message": error.message
                ])
        }
    }
}
