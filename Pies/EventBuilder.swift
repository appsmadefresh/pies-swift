//
//  EventBuilder.swift
//  Pies
//
//  Created by Robert Harrison on 11/10/21.
//

import Foundation

final class EventBuilder {
    
    static func newInstall(deviceId: String) -> [String: Any] {
        return event(eventType: .newInstall, deviceId: deviceId, userInfo: nil)
    }
    
    static func sessionStart(deviceId: String) -> [String: Any] {
        return event(eventType: .sessionStart, deviceId: deviceId, userInfo: nil)
    }
    
    static func inAppPurchase(deviceId: String, purchaseInfo: [String: Any]) -> [String: Any] {
        return event(eventType: .inAppPurchase, deviceId: deviceId, userInfo: purchaseInfo)
    }
    
    static func event(eventType: EventType, deviceId: String, userInfo: [String: Any]?) -> [String: Any] {
        
        var event: [String: Any] = [
            APIField.timestamp(): Date().timeIntervalSince1970,
            APIField.eventType(): eventType.rawValue,
            APIField.deviceId(): deviceId
        ]
        
        if let userInfo = userInfo {
            for (key, value) in userInfo {
                event[key] = value
            }
        }
        
        return event
    }
    
}
