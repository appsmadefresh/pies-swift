//
//  APIErrorField.swift
//  Pies
//
//  Created by Robert Harrison on 1/6/22.
//

import Foundation

enum APIErrorField: String {
    case stopTracking
    case stopTrackingReason
    case stopTrackingDuration
    case stopTrackingCacheEnabled
    
    func callAsFunction() -> String {
        return self.rawValue
    }
}
