//
//  ListFileService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI
import Dependencies
import GoogleDriveClient

enum ExtType: String {
    case jpeg = "jpeg"
    case pdf = "pdf"
    case mp4 = "mp4"
    case none = ""
}

enum MimeType: String {
    case jpeg = "image/jpeg"
    case pdf = "application/pdf"
    case mp4 = "video/mp4"
    case folder = "application/vnd.google-apps.folder"
    case none = ""
}

struct MyFile: Identifiable, Hashable {
    var id = UUID().uuidString
    var fileId: String
    var mimeType: MimeType
    var name: String
    var createdTime: Date
    var modifiedTime: Date
    var ext: ExtType
}

class ListFileService: ObservableObject {
    @Dependency(\.googleDriveClient) var client
    @Published var folderFiles: [MyFile] = []
    @Published var mediaFiles: [MyFile] = []
    @Published var pdfFiles: [MyFile] = []
    var tempFiles: [MyFile] = []
    
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
            await MainActor.run {
                self.folderFiles = self.addFiles(files: fileList.files)
            }
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
            tempFiles = self.addFiles(files: fileList.files)
        } catch {
            debugPrint("🧨", "ListFileService, getData() Error: \(error) localizedDescription: \(error.localizedDescription)")
        }
        do {
            let fileList = try await client.listFiles {
                $0.corpora = .user
                $0.orderBy = [.folder, .name]
                if let id = id {
                    $0.query = "mimeType='video/mp4' and '\(id)' in parents and trashed = false and 'me' in owners"
                } else {
                    $0.query = "mimeType='video/mp4' and 'root' in parents and trashed = false and 'me' in owners"
                }
            }
            tempFiles += self.addFiles(files: fileList.files)
        } catch {
            debugPrint("🧨", "ListFileService, getData() Error: \(error) localizedDescription: \(error.localizedDescription)")
        }
        do {
            let fileList = try await client.listFiles {
                $0.corpora = .user
                $0.orderBy = [.folder, .name]
                if let id = id {
                    $0.query = "mimeType='application/pdf' and '\(id)' in parents and trashed = false and 'me' in owners"
                } else {
                    $0.query = "mimeType='application/pdf' and 'root' in parents and trashed = false and 'me' in owners"
                }
            }
            tempFiles += self.addFiles(files: fileList.files)
            await MainActor.run {
                self.mediaFiles = self.tempFiles
            }
        } catch {
            debugPrint("🧨", "ListFileService, getData() Error: \(error) localizedDescription: \(error.localizedDescription)")
        }
    }
    
    func addFiles(files: [File]) -> [MyFile] {
        var myFiles: [MyFile] = []
        
        if files.isEmpty == false {
            for file in files {
                var ext: ExtType = .none
                if let mimeType: MimeType = MimeType(rawValue: file.mimeType) {
                    switch mimeType {
                    case .folder, .none:
                        ext = .none
                    case .jpeg:
                        ext = .jpeg
                    case .mp4:
                        ext = .mp4
                    case .pdf:
                        ext = .pdf
                    }
                    let item = MyFile(fileId: file.id, mimeType: mimeType, name: file.name, createdTime: file.createdTime, modifiedTime: file.modifiedTime, ext: ext)
                    myFiles.append(item)
                }
            }
        }
        return myFiles
    }
    
    
}
