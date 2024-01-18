//
//  ContentView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/8/24.
//

import Dependencies
import GoogleDriveClient
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @Dependency(\.googleDriveClient) var client
    @State var isSignedIn = false
    @State private var showSettings = false
    @State private var firstTime = true
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            if !isSignedIn {
                VStack {
                    Text("You are signed out")
                    Button {
                        Task {
                            await client.auth.signIn()
                        }
                    } label: {
                        Text("Sign In")
                    }
                }
            } else {
                HomeView()
            }
        }
        .navigationTitle("My Drive Photos")
        .onAppear {
            if firstTime {
                firebaseService.getFCM()
                firstTime = false
            }
        }
        .task {
            for await isSignedIn in client.auth.isSignedInStream() {
                self.isSignedIn = isSignedIn
            }
        }
        .onOpenURL { url in
            Task<Void, Never> {
                do {
                    _ = try await client.auth.handleRedirect(url)
                } catch {
                    debugPrint("", "Auth.HandleRedirect failure: \(error.localizedDescription)")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(isSignedIn: $isSignedIn)
        }
    }
    
}
