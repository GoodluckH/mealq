//
//  mealqApp.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import SwiftUI


@main
struct mealqApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sessionStore = SessionStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .onAppear{sessionStore.listen()}
        }
    }
}

