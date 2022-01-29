//
//  mealqApp.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import SwiftUI
import FacebookLogin
import GoogleSignIn

@main
struct mealqApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sessionStore = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .onAppear{sessionStore.listen()}
                .onOpenURL(perform: {url in
                    ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplication.OpenURLOptionsKey.annotation)
                })
        }
    }
}

