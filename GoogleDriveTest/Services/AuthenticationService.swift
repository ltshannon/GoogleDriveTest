//
//  AuthenticationService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/17/24.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications

//Class to manage firebase configuration and backend authentication
@MainActor
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    private var handler: AuthStateDidChangeListenerHandle? = nil
    @Published var user: User?
    @Published var state: AuthState = .waiting
    @Published var isGuestUser = false
    @State var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    var firebaseService = FirebaseService.shared
 
    enum AuthState: String {
        case waiting = "waiting"
        case accountSetup = "accountSetup"
        case loggedIn = "loggedIn"
        case loggedOut = "loggedOut"
    }
    
    init() {
       
        handler = Auth.auth().addStateDidChangeListener { auth, user in
            debugPrint("🛎️", "Authentication Firebase auth state changed, logged in: \(auth.userIsLoggedIn)")
            
            self.user = user
            
            DispatchQueue.main.async {
                self.isGuestUser = false
                if let isAnonymous = user?.isAnonymous {
                    self.isGuestUser = isAnonymous
                }
            }
            
            //case where user loggedin but waiting account setup
            guard self.state != .accountSetup else {
                return
            }
            
            //case where no user auth, likely first run
            guard let currentUser = auth.currentUser else {
                self.state = .loggedOut
                return
            }
            
            self.state = auth.userIsLoggedIn ? .loggedIn : .loggedOut
            
            switch self.state {
            case .waiting, .accountSetup:
                break
                
            case .loggedIn:
                debugPrint("🦁", "logged in")
            case .loggedOut:
                break
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("set badge"), object: nil, queue: nil) { notification in
            let fcm = notification.userInfo?["fcm"] as? String ?? ""
            debugPrint("fcm: \(fcm)")
            Task {
                await self.badgeManager.setAlertBadge(number: 1)
            }
        }
        
    }

    deinit {
        if let handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
}

extension Auth {
    var userIsLoggedIn: Bool {
        currentUser != nil
    }
}
