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
            event = EventBuilder.newInstall(deviceId: deviceId)
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
        
        guard NetworkMonitor.shared.isOnline else {
            EventCache.pushEvent(event)
            return
        }
        
        guard let request = APIBuilder.request(forEvent: event, appId: appId, apiKey: apiKey, useEmulator: useEmulator) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        APIQueues.shared.defaultQueue.addOperation(operation)
    }
    
    func sendCachedEvents() {
        
        guard NetworkMonitor.shared.isOnline else { return }
        
        let eventCount = EventCache.count
        for _ in 0..<eventCount {
            if let event = EventCache.popEvent() {
                sendEvent(event)
            }
        }
        
    }
}
