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
    
    private var userDefaults: UserDefaults
    private var storeObserver: StoreObserver
    private var eventEmitter: EventEmitter
    
    var deviceId: String? {
        return UserDefaults.pies.string(forKey: PiesKey.deviceId)
    }
    
    private var keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        return keychain
    }()
    
    static var useEmulator = false
    
    static private let lastAppBackgroundTimestampKey = "last-app-background-timestamp"
    static private let continueSessionInterval: TimeInterval = 5
    
    init() {
        self.userDefaults = UserDefaults.pies
        self.storeObserver = StoreObserver(userDefaults:  self.userDefaults, useEmulator: PiesManager.useEmulator)
        self.eventEmitter = EventEmitter(userDefaults:  self.userDefaults, useEmulator: PiesManager.useEmulator)
    }
    
    deinit {
        SKPaymentQueue.default().remove(storeObserver)
    }
    
    func configure(appId: String, apiKey: String, logLevel: PiesLogLevel = .info) {
        
        PiesLogger.shared.level = logLevel
        
        userDefaults.set(appId, forKey: PiesKey.appId)
        userDefaults.set(apiKey, forKey: PiesKey.apiKey)
        
        NetworkMonitor.shared.start()
        
        checkForNewInstall()
        
        SKPaymentQueue.default().add(storeObserver)
        
        PiesLogger.shared.logInfo(message: "Initialized Pies v\(String.frameworkVersion)")
    }
    
    func startListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didMoveToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func didBecomeActive() {
        
        if let lastAppBackgroundTimestamp = userDefaults.value(forKey: PiesManager.lastAppBackgroundTimestampKey) as? TimeInterval {
            let now = Date().timeIntervalSince1970
            let shouldContinueSession = now - lastAppBackgroundTimestamp <= PiesManager.continueSessionInterval
            if shouldContinueSession {
                return
            }
        }
         
        eventEmitter.sendCachedEvents()
        eventEmitter.sendEvent(ofType: .sessionStart)
        sendActiveDevice()
    }
    
    @objc private func didMoveToBackground() {
        UserDefaults.pies.set(Date().timeIntervalSince1970, forKey: PiesManager.lastAppBackgroundTimestampKey)
        
        APIQueues.shared.defaultQueue.cancelAllOperations()
    }
    
    private func checkForNewInstall() {
        
        if userDefaults.string(forKey: PiesKey.installDate) != nil { return }
        
        var installed: Date?
        if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            if let installDate = try? FileManager.default.attributesOfItem(atPath: documentsFolder.path)[.creationDate] as? Date {
                installed = installDate
            }
        }
        
        guard let installed = installed else { return }

        userDefaults.set("\(installed.timeIntervalSince1970)", forKey: PiesKey.installDate)
        
        if userDefaults.string(forKey: PiesKey.deviceId) != nil { return }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        userDefaults.set(deviceId, forKey: PiesKey.deviceId)
        
        let now = Date()
        if now.timeIntervalSince1970 - installed.timeIntervalSince1970 <= 86400 {
            // Send new install event if within 24 hours of actual app installation.
            
            // Also check if this is the first install or not
            if keychain.get(KeychainKey.firstInstallDate) == nil {
                keychain.set("\(installed.timeIntervalSince1970)", forKey: KeychainKey.firstInstallDate)
                eventEmitter.sendEvent(ofType: .newInstall, userInfo: [EventField.isFirstInstall(): true])
                
            } else {
                eventEmitter.sendEvent(ofType: .newInstall)
            }
            
            
        }
    }
    
    private func sendActiveDevice() {
        
        let now = Date()
        
        guard let deviceActiveTodayDateString = userDefaults.string(forKey: PiesKey.deviceActiveTodayDate),
              let deviceActiveThisWeekDateString = userDefaults.string(forKey: PiesKey.deviceActiveThisWeekDate),
              let deviceActiveThisMonthDateString = userDefaults.string(forKey: PiesKey.deviceActiveThisMonthDate) else {
                  
            userDefaults.set("\(now.getStartOfDay())", forKey: PiesKey.deviceActiveTodayDate)
            userDefaults.set("\(now.getStartOfWeek())", forKey: PiesKey.deviceActiveThisWeekDate)
            userDefaults.set("\(now.getStartOfMonth())", forKey: PiesKey.deviceActiveThisMonthDate)
            
            eventEmitter.sendEvent(ofType: .deviceActiveToday)
            eventEmitter.sendEvent(ofType: .deviceActiveThisWeek)
            eventEmitter.sendEvent(ofType: .deviceActiveThisMonth)
                  
            return
        }
        
        if let deviceActiveTodayDate = Int(deviceActiveTodayDateString), now.getStartOfDay() != deviceActiveTodayDate {
            userDefaults.set("\(now.getStartOfDay())", forKey: PiesKey.deviceActiveTodayDate)
            eventEmitter.sendEvent(ofType: .deviceActiveToday)
        }

        if let deviceActiveThisWeekDate = Int(deviceActiveThisWeekDateString), now.getStartOfWeek() != deviceActiveThisWeekDate {
            userDefaults.set("\(now.getStartOfWeek())", forKey: PiesKey.deviceActiveThisWeekDate)
            eventEmitter.sendEvent(ofType: .deviceActiveThisWeek)
        }

        if let deviceActiveThisMonthDate = Int(deviceActiveThisMonthDateString), now.getStartOfMonth() != deviceActiveThisMonthDate {
            userDefaults.set("\(now.getStartOfMonth())", forKey: PiesKey.deviceActiveThisMonthDate)
            eventEmitter.sendEvent(ofType: .deviceActiveThisMonth)
        }
        
    }
}
