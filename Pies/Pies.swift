//
//  Pies.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

public class Pies {
    
    /// To connect to local Firebase Emulator, set to `true` before calling Pies.configure().
    public static var useEmulator = false
    
    /// Configure Pies with your appId and apiKey that can be found in your email.
    public static func configure(appId: String, apiKey: String, logLevel: PiesLogLevel = .info) {
        if appId.isEmpty || apiKey.isEmpty {
            fatalError("You must provide a valid appId and valid apiKey.")
        }
        PiesManager.useEmulator = Pies.useEmulator
        PiesManager.shared.configure(appId: appId, apiKey: apiKey, logLevel: logLevel)
        PiesManager.shared.startListening()
    }
    
    public static var deviceId: String? {
        return PiesManager.shared.deviceId
    }
    
}
