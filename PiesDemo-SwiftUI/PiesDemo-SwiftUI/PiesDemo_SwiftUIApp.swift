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
        Pies.configure(appId: "-MmtM0u4QPsyRhTC8Puh", apiKey: "bc2e9820-0456-4c61-b785-cbf82e3c29d4")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
