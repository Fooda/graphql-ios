//
//  GraphQLJSONDecoderTests.swift
//  graphql-iosTests
//
//  Created by Blake Macnair on 6/18/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import XCTest

#if os(iOS)
  @testable import graphql_ios
#else
  @testable import graphql_macos
#endif

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

        let componentSet: Set<Calendar.Component> = Set([.timeZone, .year, .month, .day, .hour, .minute, .second])
        let components = Calendar.current.dateComponents(componentSet, from: date)
        let timeOffset: Int = TimeZone.current.secondsFromGMT() / 60 / 60
        let expectedComponents: DateComponents = .init(timeZone: .current,
                                                       year: 2014,
                                                       month: 6,
                                                       day: 13,
                                                       hour: 12 + timeOffset,
                                                       minute: 0,
                                                       second: 0)

        XCTAssertEqual(components, expectedComponents)
    }
}
