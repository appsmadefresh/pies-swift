//
//  ContentView.swift
//  PiesDemo-SwiftUI
//
//  Created by Robert Harrison on 10/6/21.
//

import SwiftUI
import Pies

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
        
            .onAppear {
                print(EventType.sessionStart)
            }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
