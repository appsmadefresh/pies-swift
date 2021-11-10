//
//  PiesManager.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import UIKit
import Network
import StoreKit

final class PiesManager {
    static let shared = PiesManager()
    
    private let networkMonitor = NWPathMonitor()
    private var isNetworkOnline = false
    private let networkMonitorQueue = DispatchQueue(label: "com.fresh.Pies.NetworkMonitor")
    
    private var storeObserver: StoreObserver
    
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
    }
    
    deinit {
        SKPaymentQueue.default().remove(storeObserver)
        networkMonitor.cancel()
    }
    
    func configure(appId: String, apiKey: String, logLevel: PiesLogLevel = .info) {
        
        PiesLogger.shared.level = logLevel
        
        keychain.set(appId, forKey: KeychainKey.appId)
        keychain.set(apiKey, forKey: KeychainKey.apiKey)
        
        startNetworkMonitor()
        
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
         
        guard let appId = keychain.get(KeychainKey.appId),
            let apiKey = keychain.get(KeychainKey.apiKey),
            let deviceId = keychain.get(KeychainKey.deviceId) else {
                PiesLogger.shared.logError(message: "Failed to track active session.")
            return
        }
        
        guard let request = APIBuilder.requestForSessionStart(appId: appId, apiKey: apiKey, deviceId: deviceId, useEmulator: PiesManager.useEmulator) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        
        APIQueues.shared.defaultQueue.addOperation(operation)
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
        
        guard let appId = keychain.get(KeychainKey.appId),
              let apiKey = keychain.get(KeychainKey.apiKey),
              let deviceId = keychain.get(KeychainKey.deviceId) else {
            return
        }
        
        guard let request = APIBuilder.requestForNewInstall(appId: appId, apiKey: apiKey, deviceId: deviceId, useEmulator: PiesManager.useEmulator) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        APIQueues.shared.defaultQueue.addOperation(operation)
    }
    
    private func startNetworkMonitor() {
        
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isNetworkOnline = path.status == .satisfied
                print("isNetworkOnline = \(self.isNetworkOnline)")
            }
        }
        
        networkMonitor.start(queue: networkMonitorQueue)
    }
}
