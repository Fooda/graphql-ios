//
//  StubManager.swift
//  graphql-iosTests
//
//  Created by Craig Olson on 6/10/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import Foundation
import OHHTTPStubs

class StubManager {
    // MARK: - Properties
    static var shared = StubManager()

    // MARK: - Public Methods
    func removeStubs() {
        OHHTTPStubs.removeAllStubs()
    }

    func stub(url urlString: String, method: String, responseStatusCode: Int32, responseBody: String? = nil, responseBodyData: Data? = nil, completion: ((URLRequest) -> Bool)? = nil) {
        let requestMatcher: (URLRequest) -> Bool = {
            isAbsoluteURLString(urlString)($0) && ($0.httpMethod?.lowercased() ?? "") == method.lowercased() && (completion?($0) ?? true)
        }
        OHHTTPStubs.stubRequests(passingTest: requestMatcher) { _ in
            let stubData = responseBody?.data(using: .utf8, allowLossyConversion: true) ?? responseBodyData ?? Data()
            return OHHTTPStubsResponse(data: stubData, statusCode: responseStatusCode, headers: nil)
        }
    }
}

extension URLRequest {
    func readBody() -> Data? {
        guard let stream = httpBodyStream else { return httpBody }
        stream.open()
        let bufferSize = 1024
        var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
            stream.close()
        }
        var read = 0
        var data = Data()
        repeat {
            read = stream.read(buffer, maxLength: bufferSize)
            guard read > 0 else { break }
            data.append(buffer, count: read)
        } while read > 0
        return data
    }
}
