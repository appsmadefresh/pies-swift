//
//  EventEmitter.swift
//  Pies
//
//  Created by Robert Harrison on 11/10/21.
//

import Foundation

final class EventEmitter {
    
    private var userDefaults: UserDefaults!
    private var useEmulator = false
    
    init(userDefaults: UserDefaults, useEmulator: Bool = false) {
        self.userDefaults = userDefaults
        self.useEmulator = useEmulator
    }
    
    func sendEvent(ofType eventType: EventType, userInfo: [String: Any]? = nil) {
        
        guard let deviceId = userDefaults.string(forKey: PiesKey.deviceId) else { return }
        
        let event: [String: Any]
        switch eventType {
        case .newInstall:
            event = EventBuilder.newInstall(deviceId: deviceId, userInfo: userInfo)
        case .sessionStart:
            event = EventBuilder.sessionStart(deviceId: deviceId)
        case .sessionEnd:
            PiesLogger.shared.logDebug(message: "Session End event are not currently supported.")
            return
        case .inAppPurchase:
            guard let userInfo = userInfo else {
                PiesLogger.shared.logDebug(message: "Cannot send inAppPurchase event with nil userInfo.")
                return
            }
            event = EventBuilder.inAppPurchase(deviceId: deviceId, purchaseInfo: userInfo)
        case .deviceActiveToday:
            event = EventBuilder.deviceActiveToday(deviceId: deviceId)
        case .deviceActiveThisWeek:
            event = EventBuilder.deviceActiveThisWeek(deviceId: deviceId)
        case .deviceActiveThisMonth:
            event = EventBuilder.deviceActiveThisMonth(deviceId: deviceId)
        }
        
        sendEvent(event)
    }
    
    func sendEvent(_ event: [String: Any]) {
        guard let appId = userDefaults.string(forKey: PiesKey.appId),
              let apiKey = userDefaults.string(forKey: PiesKey.apiKey) else {
            return
        }
        
        switch getTrackingStatus() {
        case .active: break
        case .paused:
            if userDefaults.bool(forKey: PiesKey.stopTrackingCacheEnabled) {
                EventCache.pushEvent(event)
            }
            return
        case .stopped:
            return
        }
        
        guard NetworkMonitor.shared.isOnline else {
            EventCache.pushEvent(event)
            return
        }
        
        guard let request = APIBuilder.request(forEvent: event, appId: appId, apiKey: apiKey, useEmulator: useEmulator) else { return }
        
        PiesLogger.shared.logDebug(message: "Sending Event: \(event["eventType"] ?? "unknown type")")
        
        let operation = APIOperation(request: request) { [weak self] data in
            guard let data = data else { return }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }

            if let stopTracking = json[APIErrorField.stopTracking()] as? Bool, stopTracking == true,
                let stopTrackingReason = json[APIErrorField.stopTrackingReason()] as? String,
                let stopTrackingDuration = json[APIErrorField.stopTrackingDuration()] as? Int,
                let stopTrackingCacheEnabled = json[APIErrorField.stopTrackingCacheEnabled()] as? Bool {

                let stopTrackingUntil = stopTrackingDuration > 0 ? Date().timeIntervalSince1970 + TimeInterval(stopTrackingDuration) : 0
                self?.userDefaults.set(stopTrackingUntil, forKey: PiesKey.stopTrackingUntil)
                self?.userDefaults.set(stopTrackingReason, forKey: PiesKey.stopTrackingReason)
                self?.userDefaults.set(stopTrackingCacheEnabled, forKey: PiesKey.stopTrackingCacheEnabled)
                self?.userDefaults.set(true, forKey: PiesKey.trackingStopped)
                
                if stopTrackingDuration == 0 {
                    PiesLogger.shared.logDebug(message: "Tracking stopped! Reason: \(stopTrackingReason)")
                } else {
                    
                    PiesLogger.shared.logDebug(message: "Tracking paused until \(DateFormatter.formattedString(using: stopTrackingUntil))! Reason: \(stopTrackingReason)")
                    
                    if stopTrackingCacheEnabled {
                        EventCache.pushEvent(event)
                    }
                }
            }
        }
        
        APIQueues.shared.defaultQueue.addOperation(operation)
    }
    
    func sendCachedEvents() {
        
        let trackingStopped = userDefaults.bool(forKey: PiesKey.trackingStopped)
        guard !trackingStopped else { return }
        
        guard NetworkMonitor.shared.isOnline else { return }
        
        let eventCount = EventCache.count
        for _ in 0..<eventCount {
            if let event = EventCache.popEvent() {
                sendEvent(event)
            }
        }
        
    }
    
    private func getTrackingStatus() -> TrackingStatus {
        
        // Check if event tracking has been stopped by the backend.
        let trackingStopped = userDefaults.bool(forKey: PiesKey.trackingStopped)
        
        if trackingStopped {
            let now = Date().timeIntervalSince1970
            
            guard let stopTrackingReason = userDefaults.string(forKey: PiesKey.stopTrackingReason) else {
                PiesLogger.shared.logDebug(message: "Value for stopTrackingReason is missing!")
                return .paused
            }
            
            let stopTrackingUntil = userDefaults.double(forKey: PiesKey.stopTrackingUntil)
            if stopTrackingUntil == 0 {
                // Tracking is stopped forever.
                PiesLogger.shared.logDebug(message: "Tracking stopped! Reason: \(stopTrackingReason)")
                return .stopped
            } else if now < stopTrackingUntil {
                // Tracking is paused for a duration.
                PiesLogger.shared.logDebug(message: "Tracking paused until \(DateFormatter.formattedString(using: stopTrackingUntil))! Reason: \(stopTrackingReason)")
                return .paused
            } else {
                // Resume tracking.
                userDefaults.set(false, forKey: PiesKey.trackingStopped)
                return .active
            }
            
        } else {
            return .active
        }
    }
    
}
