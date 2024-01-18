//
//  NotificationManager.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/16/24.
//

import SwiftUI
import UserNotifications

@MainActor
class NotificationManager: ObservableObject{
    static let shared = NotificationManager()
    @Published private(set) var fcmToken = ""
    
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: nil) { notification in
            let newToken = notification.userInfo?["token"] as? String ?? ""
            Task {
                await MainActor.run {
                    self.fcmToken = newToken
                }
            }
        }
    }
}
