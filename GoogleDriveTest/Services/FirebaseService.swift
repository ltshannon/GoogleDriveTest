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
    var date: Date?
    var name: String?
}

class FirebaseService: ObservableObject {
    @Published var fcms: [FCM] = []
    static let shared = FirebaseService()
    private var fcmListener: ListenerRegistration?
    
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
        @AppStorage("username") var username: String = ""
        
        do {
            try await database.collection("fcms").addDocument(data: [
                "fcm": fcm,
                "date": FieldValue.serverTimestamp(),
                "name": username
            ])
        } catch {
            debugPrint("🧨", "writeFCM failed: \(error.localizedDescription)")
        }
    }
    
    func updateFCM(fcm: String, username: String) async {

        let array = fcms.filter({ $0.fcm == fcm })
        if array.count == 1, let docId = array[0].id {
            let value = [
                "date": FieldValue.serverTimestamp(),
                "name": username
            ] as [String : Any]
            do {
                try await database.collection("fcms").document(docId).updateData(value)
                
            } catch {
                debugPrint("🧨", "updateFCM: \(error)")
            }
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
