//
//  PiesManager.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import UIKit

final class PiesManager {
    static let shared = PiesManager()
    
    private var keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        keychain.synchronizable = false
        return keychain
    }()
    
    func configure(appId: String, apiKey: String, logLevel: PiesLogLevel = .info) {
        
        PiesLogger.shared.level = logLevel
        
        keychain.set(appId, forKey: KeychainKey.appId)
        keychain.set(apiKey, forKey: KeychainKey.apiKey)
        
        checkForNewInstall()
        
        PiesLogger.shared.logInfo(message: "Initialized.")
    }
    
    func startListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func didBecomeActive() {
        
        guard let appId = keychain.get(KeychainKey.appId),
            let apiKey = keychain.get(KeychainKey.apiKey),
            let deviceId = keychain.get(KeychainKey.deviceId) else {
                PiesLogger.shared.logError(message: "Failed to track active session.")
            return
        }
        
        guard let request = APIBuilder.requestForSessionStart(appId: appId, apiKey: apiKey, deviceId: deviceId) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        
        APIQueues.shared.defaultQueue.addOperation(operation)
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
        
        guard let request = APIBuilder.requestForNewInstall(appId: appId, apiKey: apiKey, deviceId: deviceId) else { return }
        
        let operation = APIOperation(request: request) { _ in }
        APIQueues.shared.defaultQueue.addOperation(operation)
    }
}
