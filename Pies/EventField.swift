//
//  EventField.swift
//  Pies
//
//  Created by Robert Harrison on 12/8/21.
//

import Foundation

enum EventField: String {
    case appVersion
    case deviceId
    case deviceType
    case eventType
    case frameworkVersion
    case locale
    case osVersion
    case regionCode
    case timestamp
    
    func callAsFunction() -> String {
        return self.rawValue
    }
}
