//
//  PiesManager.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import UIKit
import StoreKit

final class PiesManager {
    static let shared = PiesManager()
    
    private var storeObserver: StoreObserver
    private var eventEmitter: EventEmitter
    
    private var keychain: KeychainSwift = {
        let keychain = KeychainSwift(keyPrefix: KeychainSwift.piesKeyChainPrefix)
        keychain.synchronizable = false
        return keychain
    }()
    
    var deviceId: String? {
        return keychain.get(KeychainKey.deviceId)
    }
    
    static var useEmulator = false
    
    static private let lastAppBackgroundTimestampKey = "last-app-background-timestamp"
    static private let continueSessionInterval: TimeInterval = 5
    
    init() {
        self.storeObserver = StoreObserver(keychain: keychain, useEmulator: PiesManager.useEmulator)
        self.eventEmitter = EventEmitter(keychain: keychain, useEmulator: PiesManager.useEmulator)
    }
    
    deinit {
        SKPaymentQueue.default().remove(storeObserver)
    }
    
    func configure(appId: String, apiKey: String, logLevel: PiesLogLevel = .info) {
        
        PiesLogger.shared.level = logLevel
        
        keychain.set(appId, forKey: KeychainKey.appId)
        keychain.set(apiKey, forKey: KeychainKey.apiKey)
        
        NetworkMonitor.shared.start()
        
        checkForNewInstall()
        
        SKPaymentQueue.default().add(storeObserver)
        
        PiesLogger.shared.logInfo(message: "Initialized.")
    }
    
    func startListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didMoveToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func didBecomeActive() {
        
        if let lastAppBackgroundTimestamp = UserDefaults.pies.value(forKey: PiesManager.lastAppBackgroundTimestampKey) as? TimeInterval {
            let now = Date().timeIntervalSince1970
            let shouldContinueSession = now - lastAppBackgroundTimestamp <= PiesManager.continueSessionInterval
            if shouldContinueSession {
                return
            }
        }
         
        eventEmitter.sendCachedEvents()
        eventEmitter.sendEvent(ofType: .sessionStart)
        sendActiveUser()
    }
    
    @objc private func didMoveToBackground() {
        UserDefaults.pies.set(Date().timeIntervalSince1970, forKey: PiesManager.lastAppBackgroundTimestampKey)
        
        APIQueues.shared.defaultQueue.cancelAllOperations()
    }
    
    private func checkForNewInstall() {
        
        if keychain.get(KeychainKey.installDate) != nil { return }
        
        var installed: Date?
        if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            if let installDate = try? FileManager.default.attributesOfItem(atPath: documentsFolder.path)[.creationDate] as? Date {
                installed = installDate
            }
        }
        
        guard let installed = installed else { return }

        keychain.set("\(installed.timeIntervalSince1970)", forKey: KeychainKey.installDate)
        
        if keychain.get(KeychainKey.deviceId) != nil { return }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        keychain.set(deviceId, forKey: KeychainKey.deviceId)
        
        let now = Date()
        if now.timeIntervalSince1970 - installed.timeIntervalSince1970 <= 86400 {
            // Send new install event if within 24 hours of actual app installation.
            eventEmitter.sendEvent(ofType: .newInstall)
        }
    }
    
    private func sendActiveUser() {
        
        let now = Date()
        
        guard let userActiveTodayDateString = keychain.get(KeychainKey.userActiveTodayDate),
              let userActiveThisWeekDateString = keychain.get(KeychainKey.userActiveThisWeekDate),
              let userActiveThisMonthDateString = keychain.get(KeychainKey.userActiveThisMonthDate) else {
            
            keychain.set("\(now.getStartOfDay())", forKey: KeychainKey.userActiveTodayDate)
            keychain.set("\(now.getStartOfWeek())", forKey: KeychainKey.userActiveThisWeekDate)
            keychain.set("\(now.getStartOfMonth())", forKey: KeychainKey.userActiveThisMonthDate)
            
            eventEmitter.sendEvent(ofType: .userActiveToday)
            eventEmitter.sendEvent(ofType: .userActiveThisWeek)
            eventEmitter.sendEvent(ofType: .userActiveThisMonth)
                  
            return
        }
        
        if let userActiveTodayDate = Int(userActiveTodayDateString), now.getStartOfDay() != userActiveTodayDate {
            keychain.set("\(now.getStartOfDay())", forKey: KeychainKey.userActiveTodayDate)
            eventEmitter.sendEvent(ofType: .userActiveToday)
        }

        if let userActiveThisWeekDate = Int(userActiveThisWeekDateString), now.getStartOfWeek() != userActiveThisWeekDate {
            keychain.set("\(now.getStartOfWeek())", forKey: KeychainKey.userActiveThisWeekDate)
            eventEmitter.sendEvent(ofType: .userActiveThisWeek)
        }

        if let userActiveThisMonthDate = Int(userActiveThisMonthDateString), now.getStartOfMonth() != userActiveThisMonthDate {
            keychain.set("\(now.getStartOfMonth())", forKey: KeychainKey.userActiveThisMonthDate)
            eventEmitter.sendEvent(ofType: .userActiveThisMonth)
        }
        
    }
}
