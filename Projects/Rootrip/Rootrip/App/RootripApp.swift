//
//  RootripApp.swift
//  Rootrip
//
//  Created by eunsoo on 7/17/25.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var locationManager = LocationManager()
    @StateObject var planManager = PlanManager()
    @StateObject var bookmarkManager = BookmarkManager()
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(locationManager)
                .environmentObject(planManager)
                .environmentObject(bookmarkManager)
        }
    }
}
