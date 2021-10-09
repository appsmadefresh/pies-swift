//
//  Pies.swift
//  Pies
//
//  Created by Robert Harrison on 10/8/21.
//

import Foundation

public class Pies {
    
    /// Configure Pies with your appId and apiKey that can be found in your email.
    // TODO: add logLevel
    public static func configure(appId: String, apiKey: String) {
        if appId.isEmpty || apiKey.isEmpty {
            fatalError("You must provide a valid appId and valid apiKey.")
        }
        PiesManager.shared.configure(appId: appId, apiKey: apiKey)
        PiesManager.shared.startListening()
    }
    
}
