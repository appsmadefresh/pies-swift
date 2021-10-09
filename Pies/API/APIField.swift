//
//  APIField.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

enum APIField: String {
    case appId
    case apiKey
    case event
    case timestamp
    case eventType
    case deviceId
    
    func callAsFunction() -> String {
        return self.rawValue
    }
}
