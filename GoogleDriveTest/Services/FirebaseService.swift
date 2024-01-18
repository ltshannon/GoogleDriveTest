//
//  FirebaseService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/16/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFunctions
import FirebaseFirestoreSwift

let database = Firestore.firestore()

struct FCM: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var fcm: String
}

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private var fcmListener: ListenerRegistration?
    @Published var fcms: [FCM] = []
    
    func getFCM() {
        let listener = database.collection("fcms").addSnapshotListener { querySnapshot, error in

            guard let documents = querySnapshot?.documents else {
                debugPrint("🧨", "getFCMs no documents")
                return
            }
            
            var items: [FCM] = []
            for document in documents {
                do {
                    let fcm = try document.data(as: FCM.self)
                    items.append(fcm)
                }
                catch {
                    debugPrint("🧨", "\(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                self.fcms = items
            }

        }
        fcmListener = listener
    }
    
    func readFCMs() async -> [FCM]? {
        do {
            let querySnapshot = try await database.collection("fcms").getDocuments()
            let items = querySnapshot.documents.compactMap { queryDocumentSnapshot -> FCM? in
                return try? queryDocumentSnapshot.data(as: FCM.self)
            }
            return items
        } catch {
            debugPrint("🧨", "readFCMs failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func writeFCM(fcm: String) async {
        do {
            try await database.collection("fcms").addDocument(data: [
                "fcm": fcm
            ])
        } catch {
            debugPrint("🧨", "writeFCM failed: \(error.localizedDescription)")
        }
    }
    
    func callFirebaseCallableFunction(data: String) {
        lazy var functions = Functions.functions()
        
        functions.httpsCallable("sendNotifications").call(["body": data]) { result, error in
            if let error = error {
                debugPrint("🧨", "error: \(error.localizedDescription)")
                return
            }
            if let data = result?.data {
                debugPrint("😀", "result: \(data)")
            }
            
        }
    }
    
}
