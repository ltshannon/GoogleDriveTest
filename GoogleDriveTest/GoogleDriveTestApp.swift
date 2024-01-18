//
//  GoogleDriveTestApp.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

@main
struct GoogleDriveTestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var columnStepperEnv: ColumnStepperEnv = ColumnStepperEnv(gridColumns: Array(repeating: GridItem(.flexible()), count: 3), numColumns: 3)
    @StateObject var saveFielService = SaveFileService()
    @StateObject var notificationManager = NotificationManager.shared
    @StateObject var authenticationService = AuthenticationService.shared
    @StateObject var firebaseService = FirebaseService.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(columnStepperEnv)
            .environmentObject(saveFielService)
            .environmentObject(notificationManager)
            .environmentObject(firebaseService)
            .environmentObject(authenticationService)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        debugPrint("🧨", "didReceiveRemoteNotification userInfo: \(userInfo)")
        
        if let title = userInfo["title"] as? String, let fcm = userInfo["fcm"] as? String, title == "set badge" {
            let dataDict: [String: String] = ["fcm" : fcm]
            NotificationCenter.default.post(
                name: Notification.Name("set badge"),
                object: nil,
                userInfo: dataDict
            )
        }
        
        return UIBackgroundFetchResult.newData
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("🛎️", "willPresent")
        process(notification)
        completionHandler([[.banner, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint("🛎️", "didReceive ")
        process(response.notification)
        completionHandler()
    }
    
    private func process(_ notification: UNNotification) {
        let _ = notification.request.content.userInfo
        UNUserNotificationCenter.current().setBadgeCount(1) { error in
            if let error = error {
                debugPrint("Error setBadgeCount: \(error.localizedDescription)")
            }
        }

    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            debugPrint("🌎", "fcm: \(fcm)")
            let tokenDict = ["token": fcm]
            NotificationCenter.default.post(
                name: Notification.Name("FCMToken"),
                object: nil,
                userInfo: tokenDict)
        }
    }
    
}

