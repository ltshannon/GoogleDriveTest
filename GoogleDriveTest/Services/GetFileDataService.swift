//
//  GetFileDataService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI
import Dependencies
import GoogleDriveClient

class GetFileDataService: ObservableObject {
    @Dependency(\.googleDriveClient) var client
    @Published var imageData: Data?
    var fileManagerService = FileManagerService()

    func getData(id: String) async {
        do {
            if let data = fileManagerService.getImageData(id: id) {
                DispatchQueue.main.async {
                    self.imageData = data
                }
                return
            }
            let params = GetFileData.Params(fileId: id)
            let data = try await client.getFileData(params)
            
            fileManagerService.saveImageData(data: data, id: id)
            
            DispatchQueue.main.async {
                self.imageData = data
            }
        } catch {
            debugPrint("🧨", "GetFileDataService, getData() Error: \(error) localizedDescription: \(error.localizedDescription)")
        }
    }
    
}
