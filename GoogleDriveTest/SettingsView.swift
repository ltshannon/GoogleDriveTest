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
    @Environment(\.presentationMode) var presentationMode
    @Binding var isSignedIn: Bool
    
    var body: some View {
        VStack {
            if isSignedIn {
                Text("You are signed in")
                Button(role: .destructive) {
                    Task {
                        await client.auth.signOut()
                        isSignedIn = false
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Sign Out")
                        .DefaultTextButtonStyle()
                }
            } else {
                Text("You are signed out")
            }
            Button(role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .DefaultTextButtonStyle()
            }
        }
        .padding()
    }
}
