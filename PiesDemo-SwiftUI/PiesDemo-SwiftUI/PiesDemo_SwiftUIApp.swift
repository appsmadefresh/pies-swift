//
//  PiesDemo_SwiftUIApp.swift
//  PiesDemo-SwiftUI
//
//  Created by Robert Harrison on 10/6/21.
//

import SwiftUI
import Pies

@main
struct PiesDemo_SwiftUIApp: App {
    
    init() {
        Pies.configure(appId: "1234", apiKey: "123456789")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
