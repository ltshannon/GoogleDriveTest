//
//  FileManagerService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/12/24.
//

import SwiftUI

class FileManagerService {
    static let instance = FileManagerService()
    
    func saveImageData(data: Data, id: String) {
        
        guard let path = getPathForData(id: id) else { return }

        do {
            try data.write(to: path)
        } catch {
            debugPrint("🧨", "FileManagerService: writing data")
        }
    }
    
    func getImageData(id: String) -> Data? {
        
        guard let path = getPathForData(id: id) else { return nil }
        guard FileManager.default.fileExists(atPath: path.path) else {
            debugPrint("🧨", "FileManagerService: file does not exist")
            return nil
        }
        
        return FileManager.default.contents(atPath: path.path)

    }
    
    func getPathForData(id: String) -> URL? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).jpg") else {
            debugPrint("🧨", "FileManagerService: getting path")
            return nil
        }
        return path
        
    }
    
}
