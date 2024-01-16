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
    @Environment(\.dismiss) var dismiss
    @Binding var isSignedIn: Bool
    @State var showPrivatePolicy = false
    
    var body: some View {
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
                dismiss()
            } label: {
                Text("Cancel")
                    .DefaultTextButtonStyle()
            }
        }
        .padding()
    }
}
