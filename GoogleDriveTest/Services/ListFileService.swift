//
//  ListFileService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI
import Dependencies
import GoogleDriveClient

struct MyFile: Identifiable, Hashable {
    var id = UUID().uuidString
    var fileId: String
    var mimeType: String
    var name: String
    var createdTime: Date
    var modifiedTime: Date
}

class ListFileService: ObservableObject {
    @Dependency(\.googleDriveClient) var client
    @Published var folderFiles: [MyFile] = []
    @Published var imageFiles: [MyFile] = []
    
    func getData(_ id: String?) async {
        do {
            let fileList = try await client.listFiles {
                $0.corpora = .user
                $0.orderBy = [.folder, .name]
                if let id = id {
                    $0.query = "mimeType='application/vnd.google-apps.folder' and '\(id)' in parents and trashed = false and 'me' in owners"
                } else {
                    $0.query = "mimeType = 'application/vnd.google-apps.folder' and 'root' in parents and trashed = false and 'me' in owners"
                }
                
            }
            addFiles(files: fileList.files)
        } catch {
            debugPrint("🧨", "ListFileService, getData() Error: \(error) localizedDescription: \(error.localizedDescription)")
        }
        do {
            let fileList = try await client.listFiles {
                $0.corpora = .user
                $0.orderBy = [.folder, .name]
                if let id = id {
                    $0.query = "mimeType='image/jpeg' and '\(id)' in parents and trashed = false and 'me' in owners"
                } else {
                    $0.query = "mimeType='image/jpeg' and 'root' in parents and trashed = false and 'me' in owners"
                }
            }
            addFiles(files: fileList.files)
        } catch {
            debugPrint("🧨", "ListFileService, getData() Error: \(error) localizedDescription: \(error.localizedDescription)")
        }
    }
    
    func addFiles(files: [File]) {
        var myFiles: [MyFile] = []
        if files.isEmpty == false {
            for file in files {
                let item = MyFile(fileId: file.id, mimeType: file.mimeType, name: file.name, createdTime: file.createdTime, modifiedTime: file.modifiedTime)
                myFiles.append(item)
            }
            if myFiles.isEmpty == false {
                DispatchQueue.main.async {
                    if myFiles[0].mimeType == "application/vnd.google-apps.folder" {
                        self.folderFiles = myFiles
                    } else {
                        self.imageFiles = myFiles
                    }
                }
            }
        }
    }
    
    
}
