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
    var images: [MyFile] = []
    @State var currentFile =  MyFile(id: "", fileId: "", mimeType: "", name: "", createdTime: Date(), modifiedTime: Date())
    @State var leftArrow = true
    @State var rightArrow = true
    @State var leftFile: MyFile = MyFile(id: "", fileId: "", mimeType: "", name: "", createdTime: Date(), modifiedTime: Date())
    @State var rightFile: MyFile = MyFile(id: "", fileId: "", mimeType: "", name: "", createdTime: Date(), modifiedTime: Date())
    
    var body: some View {
        VStack {
            if let data = getFileDataService.imageData, let uiImage = UIImage(data: data) {
                HStack {
                    Button {
                        currentFile = leftFile
                        loadImageFile(id: currentFile.fileId)
                        setArrows()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                    .disabled(leftArrow)
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                    Button {
                        currentFile = rightFile
                        loadImageFile(id: currentFile.fileId)
                        setArrows()
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                    .disabled(rightArrow)
                }
                Button("Save Image to photo library") {
                    imageSaver.writeToPhotoAlbum(image: uiImage)
                }
                .DefaultTextButtonStyle()
                Spacer()
            }
        }
        .onAppear {
            guard images.count > 0 else { return }
            currentFile = file
            loadImageFile(id: currentFile.fileId)
            setArrows()
        }
        .alert("Save Image", isPresented: $imageSaver.showSaved) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Succeeded")
        }
    }
    
    func loadImageFile(id: String) {
        Task {
            await getFileDataService.getData(id: id)
        }
    }
    
    func setArrows() {
        if images.count == 1 { return }
        if let index = images.firstIndex(where: { $0.id == currentFile.id }) {
            if images.count == 2 {
                if index == 0 {
                    rightArrow = false
                    rightFile = images[index + 1]
                    leftArrow = true
                    return
                } else {
                    leftArrow = false
                    leftFile = images[index - 1]
                    rightArrow = true
                    return
                }
            }
            if index < images.count - 1 {
                rightArrow = false
                rightFile = images[index + 1]
            } else {
                rightArrow = true
            }
            if index > 0 {
                leftArrow = false
                leftFile = images[index - 1]
            } else {
                leftArrow = true
            }
        }
    }
}
