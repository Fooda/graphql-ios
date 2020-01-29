//
//  GraphQLJSONDecoderTests.swift
//  graphql-iosTests
//
//  Created by Blake Macnair on 6/18/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest
@testable import graphql_ios

final class GraphQLJSONDecoderTests: XCTestCase {
    func testDecodeDateFromString() {
        let jsonDecoder = GraphQLJSONDecoder()
        let isoString = """
                        ["2014-06-13T12:00:00+00:00"]
                        """

        guard let data = isoString.data(using: .unicode),
            let dates = try? jsonDecoder.decode([Date].self, from: data),
            let date = dates.first else {
                XCTFail("Couldn't convert string to data or date object.")
                return
        }

        let expectedDate = DateFormatter.iso8601Formatter.date(from: "2014-06-13T12:00:00+00:00")
        XCTAssertEqual(date, expectedDate)
    }
}
