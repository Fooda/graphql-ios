//
//  String+Extra.swift
//  graphql-ios
//
//  Created by Craig Olson on 6/4/19.
//  Copyright © 2019 Fooda. All rights reserved.
//

extension String {
    func localized(_ arguments: [CVarArg] = []) -> String {
        if arguments.isEmpty {
            return NSLocalizedString(self, comment: "")
        }
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
