//
//  ImageSaverService.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/13/24.
//

import SwiftUI

class ImageSaverService: NSObject {
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
