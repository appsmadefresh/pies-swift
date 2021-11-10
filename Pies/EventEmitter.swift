//
//  EventEmitter.swift
//  Pies
//
//  Created by Robert Harrison on 11/10/21.
//

import Foundation

final class EventEmitter {
    
    private var keychain: KeychainSwift
    private var useEmulator = false
    
    init(keychain: KeychainSwift, useEmulator: Bool = false) {
        self.keychain = keychain
        self.useEmulator = useEmulator
    }
    
    func sendEvent(ofType eventType: EventType, userInfo: [String: Any]? = nil) {
        
        guard let appId = keychain.get(KeychainKey.appId),
              let apiKey = keychain.get(KeychainKey.apiKey),
              let deviceId = keychain.get(KeychainKey.deviceId) else {
            return
        }
        
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
        }
        
        guard NetworkMonitor.shared.isOnline else {
            EventCache.pushEvent(event)
            return
        }
        
        guard let request = APIBuilder.request(forEvent: event, appId: appId, apiKey: apiKey, useEmulator: useEmulator) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        APIQueues.shared.defaultQueue.addOperation(operation)
    }
}
