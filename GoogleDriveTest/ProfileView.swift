//
//  ProfileView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/23/24.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("username") var username: String = ""
    @Environment(\.dismiss) private var dismiss
    @State var name = ""
    
    var body: some View {
        VStack {
            Form {
                Section("Name") {
                    TextField("Enter your name", text: $name, onCommit: {
                        print("commit")
                    })
                }
                Button {
                    username = name
                    dismiss()
                    
                } label: {
                    Text("Save")
                        .DefaultTextButtonStyle()
                }
                Button {
                    dismiss()
                    
                } label: {
                    Text("Cancel")
                        .DefaultTextButtonStyle()
                }
            }
            Spacer()
        }
        .onAppear {
            name = username
        }
    }
}

#Preview {
    ProfileView()
}
