//
//  SettingsView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import Dependencies
import GoogleDriveClient
import SwiftUI

struct SettingsView: View {
    @Dependency(\.googleDriveClient) var client
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.dismiss) var dismiss
    @Binding var isSignedIn: Bool
    @State var showPrivatePolicy = false
    @State private var showingAlert = false
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if isSignedIn {
                    Text("You are signed in")
                    Button(role: .destructive) {
                        Task {
                            await client.auth.signOut()
                            isSignedIn = false
                            dismiss()
                        }
                    } label: {
                        Text("Sign Out")
                            .DefaultTextButtonStyle()
                    }
                } else {
                    Text("You are signed out")
                }
                Link("Privacy Policy", destination: URL(string: "https://drive.google.com/file/d/17PeKroJCJooojBkip4nYA5syXAQRgQZO/view?usp=sharing")!)
                    .DefaultTextButtonStyle()
                Button(role: .destructive) {
                    showingAlert = true
                } label: {
                    Text("Send Notification")
                        .DefaultTextButtonStyle()
                }
                NavigationLink {
                    DisplayFCMsView()
                } label: {
                    Text("Display FCMs")
                        .DefaultTextButtonStyle()
                }
                NavigationLink {
                    ProfileView()
                } label: {
                    Text("Profile")
                        .DefaultTextButtonStyle()
                }
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .DefaultTextButtonStyle()
                }
            }
            .padding()
            .alert("Send Noticiation", isPresented: $showingAlert) {
                TextField("Enter your text", text: $text)
                Button("OK", action: callFirebaseFunction)
            } message: {
                Text("Enter text you would like to send in the noticiation")
            }
        }
    }
    
    func callFirebaseFunction() {
        firebaseService.callFirebaseCallableFunction(data: text)
    }
}
