//
//  DownloadImageView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI
import PDFKit
import AVKit

struct DownloadImageView: View {
    @ObservedObject var getFileDataService: GetFileDataService = GetFileDataService()
    @ObservedObject var imageSaver = ImageSaverService()
    var file: MyFile
    var images: [MyFile] = []
    @State var currentFile =  MyFile(id: "", fileId: "", mimeType: .none, name: "", createdTime: Date(), modifiedTime: Date(), ext: .none)
    @State var leftArrow = true
    @State var rightArrow = true
    @State var leftFile: MyFile = MyFile(id: "", fileId: "", mimeType: .none, name: "", createdTime: Date(), modifiedTime: Date(), ext: .none)
    @State var rightFile: MyFile = MyFile(id: "", fileId: "", mimeType: .none, name: "", createdTime: Date(), modifiedTime: Date(), ext: .none)
    @State private var rotate = 0.0
    
    var body: some View {
        VStack {
            if let data = getFileDataService.imageData {
                HStack {
                    Button {
                        currentFile = leftFile
                        loadImageFile(file: currentFile)
                        setArrows()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                    .disabled(leftArrow)
                    switch currentFile.mimeType {
                    case .jpeg:
                        DisplayImage(data: data)
                    case .pdf:
                        DisplayPDF(file: currentFile)
                    case .mp4:
                        DisplayMP4(file: currentFile)
                    case .folder:
                        Text("")
                    case .none:
                        Text("")
                    }

                    Button {
                        currentFile = rightFile
                        loadImageFile(file: currentFile)
                        setArrows()
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                    .disabled(rightArrow)
                }
                .rotationEffect(.degrees(rotate))
                .animation(.easeIn, value: rotate)
                if currentFile.mimeType == .jpeg {
                    Button("Save Image to photo library") {
                        if let uiImage = UIImage(data: data) {
                            imageSaver.writeToPhotoAlbum(image: uiImage)
                        }
                    }
                    .DefaultTextButtonStyle()
                }
                Spacer()
                Button {
                    rotate += 90
                } label: {
                    Text("Rotate")
                }
                .DefaultTextButtonStyle()
                Spacer()
            }
        }
        .onAppear {
            guard images.count > 0 else { return }
            currentFile = file
            loadImageFile(file: currentFile)
            setArrows()
        }
        .alert("Save Image", isPresented: $imageSaver.showSaved) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Succeeded")
        }
    }
    
    func loadImageFile(file: MyFile) {
        Task {
            await getFileDataService.getData(file: file)
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

struct DisplayImage: View {
    var data: Data
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    var body: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(currentZoom + totalZoom)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            currentZoom = value.magnification - 1
                        }
                        .onEnded { value in
                            totalZoom += currentZoom
                            currentZoom = 0
                        }
                )
                .accessibilityZoomAction { action in
                    if action.direction == .zoomIn {
                        totalZoom += 1
                    } else {
                        totalZoom -= 1
                    }
                }
        }
    }
}

struct DisplayPDF: View {
    var file: MyFile
    var fileManagerService = FileManagerService()
    
    var body: some View {
        if let url = fileManagerService.getPathForData(file: file), let pdfDoc = PDFDocument(url: url) {
            PDFKitView(showing: pdfDoc)
                .scaledToFit()
        }
    }
}

struct DisplayMP4: View {
    var file: MyFile
    var fileManagerService = FileManagerService()
    
    var body: some View {
        if let url = fileManagerService.getPathForData(file: file) {
            VideoPlayer(player: AVPlayer(url: url))
                .scaledToFit()
        }
    }
}
