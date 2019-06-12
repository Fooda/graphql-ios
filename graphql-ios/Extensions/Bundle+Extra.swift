//
//  Bundle+Extra.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/4/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

extension Bundle {
    static var appVersion: String {
        return main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "/"
    }

    static var bundleId: String? {
        return main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
    }
}
