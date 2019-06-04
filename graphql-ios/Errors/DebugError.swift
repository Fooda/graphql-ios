//
//  DebugError.swift
//  iFooda
//
//  Created by Craig Olson on 5/29/19.
//  Copyright © 2019 Fooda, Inc. All rights reserved.
//

protocol DebugError: LocalizedError {
    var debugDescription: String { get }
}
