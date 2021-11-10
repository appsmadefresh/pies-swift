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
        let keychain = KeychainSwift()
        keychain.synchronizable = false
        return keychain
    }()
    
    var deviceId: String? {
        return keychain.get(KeychainKey.deviceId)
    }
    
    static var useEmulator = false
    
    static private let lastAppBackgroundTimestampKey = "last-app-background-timestamp"
    static private let continueSessionInterval: TimeInterval = 2
    
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
         
        eventEmitter.sendEvent(ofType: .sessionStart)
    }
    
    @objc private func didMoveToBackground() {
        UserDefaults.pies.set(Date().timeIntervalSince1970, forKey: PiesManager.lastAppBackgroundTimestampKey)
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
        
        keychain.set(UUID().uuidString, forKey: KeychainKey.deviceId)
        
        eventEmitter.sendEvent(ofType: .newInstall)
    }
}
