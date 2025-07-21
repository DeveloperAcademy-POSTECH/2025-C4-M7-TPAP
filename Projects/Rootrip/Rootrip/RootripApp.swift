//
//  RootripApp.swift
//  Rootrip
//
//  Created by eunsoo on 7/17/25.
//

import SwiftUI
import Firebase

@main
struct RootripApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
