//
//  SaveFileService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/14/24.
//

import SwiftUI
import Dependencies
import GoogleDriveClient

class SaveFileService: ObservableObject  {
    @Dependency(\.googleDriveClient) var client
    @Published var showError = false
    @Published var showSuccess = false
    @Published var fileUploadFailedMessage = ""
    
    func saveFile(id: String?, data: Data) async {
        do {
            var directory = "root"
            if let id = id {
                directory = id
            }
            let filename = UUID().uuidString + ".jpeg"
            _ = try await client.createFile(name: filename,
                                            spaces: "appDataFolder",
                                            mimeType: "mimeType='image/jpeg",
                                            parents: [directory],
                                            data: data)
            debugPrint("😜", "saveFile completed")
            await MainActor.run {
                self.showSuccess = true
            }
        } catch {
            debugPrint("🧨", "\(error.localizedDescription)")
            await MainActor.run {
                self.showError = true
                self.fileUploadFailedMessage = error.localizedDescription
            }
        }
    }
    
}
