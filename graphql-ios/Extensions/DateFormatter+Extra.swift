//
//  DateFormatter+Extra.swift
//  graphql-ios
//
//  Created by Jake Hergott on 6/19/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
}
