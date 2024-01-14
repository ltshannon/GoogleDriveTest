//
//  DownloadImageView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI

struct DownloadImageView: View {
    @ObservedObject var getFileDataService: GetFileDataService = GetFileDataService()
    var file: MyFile
    
    var body: some View {
        VStack {
            if let data = getFileDataService.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                Button("Save Image to photo library") {
                    let imageSaver = ImageSaverService()
                    imageSaver.writeToPhotoAlbum(image: uiImage)
                }
                .DefaultTextButtonStyle()
            }
        }
        .task {
            await getFileDataService.getData(id: file.fileId)
        }
    }
}
