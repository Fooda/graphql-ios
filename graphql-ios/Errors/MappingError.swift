//
//  MappingError.swift
//  iFooda
//
//  Created by Jake Hergott on 8/31/17.
//  Copyright © 2017 Fooda, Inc. All rights reserved.
//

import Foundation

// TODO: Deprecate
public enum MappingError: DebugError {
    case unexpectedJSON
    case unexpectedUserInfo

    public var errorDescription: String? {
        switch self {
        case .unexpectedJSON:
            return "Invalid response".localized()
        case .unexpectedUserInfo:
            return "Invalid object".localized()
        }
    }

    public var debugDescription: String {
        switch self {
        case .unexpectedJSON:
            return "unexpected_json"
        case .unexpectedUserInfo:
            return "unexpected_user_info"
        }
    }
}
