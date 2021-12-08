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
    case event
    
    func callAsFunction() -> String {
        return self.rawValue
    }
}
