//
//  KeychainKey.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

enum KeychainKey {
    static let appId = "pies-keychain-app-id"
    static let apiKey = "pies-keychain-api-key"
    static let deviceId = "pies-keychain-device-id"
    static let installDate = "pies-keychain-install-date"
}

extension KeychainSwift {
    
    static var piesKeyChainPrefix: String {
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            PiesLogger.shared.logError(message: "Please set a bundle identifier in the main bundle.")
            return ""
        }
        
        return "\(bundleId)-"
    }
}
