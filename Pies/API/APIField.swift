//
//  APIField.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

enum APIField: String {
    case apiKey
    case appId
    case appVersion
    case deviceId
    case deviceType
    case event
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
