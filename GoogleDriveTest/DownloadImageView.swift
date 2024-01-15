//
//  DownloadImageView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI

struct DownloadImageView: View {
    @ObservedObject var getFileDataService: GetFileDataService = GetFileDataService()
    @ObservedObject var imageSaver = ImageSaverService()
    var file: MyFile
    
    var body: some View {
        VStack {
            if let data = getFileDataService.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                Button("Save Image to photo library") {
                    imageSaver.writeToPhotoAlbum(image: uiImage)
                }
                .DefaultTextButtonStyle()
            }
        }
        .task {
            await getFileDataService.getData(id: file.fileId)
        }
        .alert("Save Image", isPresented: $imageSaver.showSaved) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Succeeded")
        }
    }
}
