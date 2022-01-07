//
//  UserDefaults+Pies.swift
//  Pies
//
//  Created by Robert Harrison on 11/2/21.
//

import Foundation

enum PiesKey {
    static let appId = "app-id"
    static let apiKey = "api-key"
    static let deviceId = "device-id"
    static let installDate = "install-date"
    static let deviceActiveTodayDate = "device-active-today-date"
    static let deviceActiveThisWeekDate = "device-active-this-week-date"
    static let deviceActiveThisMonthDate = "device-active-this-month-date"
    static let stopTrackingUntil = "stop-tracking-until"
    static let stopTrackingReason = "stop-tracking-reason"
    static let trackingStopped = "tracking-stopped"
    static let stopTrackingCacheEnabled = "stop-tracking-cache-enabled"
}

extension UserDefaults {
    static var pies: UserDefaults {
        return UserDefaults(suiteName: "group.pies.framework")!
    }
}
