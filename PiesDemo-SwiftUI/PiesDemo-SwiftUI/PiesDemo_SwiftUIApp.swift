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
        Pies.configure(appId: "YOUR APP ID", apiKey: "YOUR API KEY")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
