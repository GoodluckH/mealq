//
//  AppDelegate.swift
//  mealq
//
//  Created by Xipu Li on 11/8/21.
//

import Foundation
import Firebase
import FirebaseMessaging
import FacebookCore
import FacebookLogin
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let sharedViewManager = ViewManager.sharedViewManager
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
     
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        Messaging.messaging().delegate = self
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        let typeAction = UNTextInputNotificationAction(identifier: "SEND_MESSAGE", title: "Reply", options: [], textInputButtonTitle: "Send", textInputPlaceholder: "send a message")
        let messageReceivedCategory = UNNotificationCategory (identifier: "MESSAGE_RECEIVED", actions: [typeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([messageReceivedCategory])
        
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]

        // 1
        if let _ = notificationOption as? [String: AnyObject] {
            print("launched from notification")
           // self.sharedViewManager.launchedWhenAppNotRunning = true
        }

        
        
        return true
    }
    
    func application(_ application: UIApplication,
                       didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)
      }
    
      func application(_ application: UIApplication,
                       didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                         -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
      }
    
      func application(_ application: UIApplication,
                       didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
      }

      // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
      // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
      // the FCM registration token.
      func application(_ application: UIApplication,
                       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
      }
    
    
    
    // set this so that people can log in with their Facebook app
//    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
//        UIApplication.shared.applicationIconBadgeNumber = 0
//        guard let firebaseUI = FUIAuth.defaultAuthUI() else { return false }
//        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//        let handled = firebaseUI.handleOpen(url, sourceApplication: sourceApplication)
//        return handled
//    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)
      
      var notificationType: UNNotificationPresentationOptions = []
      
      let application = UIApplication.shared
      
   //   sharedViewManager.launchedWhenAppNotRunning = false
      if (application.applicationState == .active) {
          // TODO: Deliver in-app notification bar
         
      }
      
      
      if (application.applicationState == .inactive) {
          notificationType = [.banner, .list, .badge, .sound]
          
//          if let mealID = userInfo["MEAL_ID"] as? String {
//              if let currentMealID = sharedViewManager.currentMealChatSession {
//                  if mealID == currentMealID {
//                      notificationType = []
//                  }
//              }
//          }
          
      }

      
      
    completionHandler(notificationType)

  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo

      print(userInfo)
      
      
      let title = response.notification.request.content.title
      let body = response.notification.request.content.body
      let category = response.notification.request.content.categoryIdentifier
      
      switch category {
      case "MESSAGE_RECEIVED":
              sharedViewManager.toggleChatView(of: userInfo["MEAL_ID"] as! String)
      default:
          break
      }
      
      
      if category == "MESSAGE_RECEIVED" {
          print("COrrect!")
      }
      
      
      switch response.actionIdentifier {
      case "SEND_MESSAGE":
          print("HAHAH")
          print(title)
          print(body)
          break
      default: break
      }
      

    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
    // Note: This callback is fired at each app startup and whenever a new token is generated.
      
  }

}


