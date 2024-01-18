//
//  HomeView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI
import Dependencies
import GoogleDriveClient
import PhotosUI

struct HomeView: View {
    @EnvironmentObject var columnStepperEnv: ColumnStepperEnv
    @EnvironmentObject var saveFileService: SaveFileService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.scenePhase) var scenePhase
    @Dependency(\.googleDriveClient) var client
    @ObservedObject var listFileService: ListFileService = ListFileService()
    var fileId: String? = nil
    @State private var isAddingPhoto = false
    @State private var isEditing = false
    @State private var hasAppeared = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var fileUploadFailedMessage = ""
    @State private var showUploadError = false
    @State var badgeManager = AppAlertBadgeManager(application: UIApplication.shared)
    
    private var columnsTitle: String {
        columnStepperEnv.gridColumns.count > 1 ? "\(columnStepperEnv.gridColumns.count) Columns" : "1 Column"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                ColumnStepper(title: columnsTitle, range: 1...8)
                    .padding([.leading, .trailing])
            }
            ScrollView {
                ForEach(listFileService.folderFiles, id: \.self) { item in
                    NavigationLink {
                        HomeView(fileId: item.fileId)
                    } label: {
                        Text(item.name)
                            .DefaultTextButtonStyle()
                    }
                }
                LazyVGrid(columns: columnStepperEnv.gridColumns) {
                    ForEach(listFileService.imageFiles) { item in
                        GeometryReader { geo in
                            NavigationLink {
                                DownloadImageView(file: item)
                            } label: {
                                GridItemView(size: geo.size.width, file: item)
                            }
                        }
                        .cornerRadius(8.0)
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding()
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text("Upload a photo to this folder")
                        .DefaultTextButtonStyle()
                }
            }
            .refreshable {
                Task {
                    await listFileService.getData(fileId != nil ? fileId : nil)
                }
            }
        }
        .onAppear {
            guard hasAppeared == false else { return }
            hasAppeared = true
            Task {
                await listFileService.getData(fileId != nil ? fileId : nil)
            }
            UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (_, _) in }
            badgeManager.resetAlertBadgetNumber()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                badgeManager.resetAlertBadgetNumber()
            }
        }
        .onChange(of: selectedItem) { newItem, oldItem in
            guard let item = newItem else {
                debugPrint("🧨", "newItem not present")
                DispatchQueue.main.async {
                    fileUploadFailedMessage = "Something went wrong uploading the file, try again."
                    showUploadError = true
                }
                return
            }
            Task {
                // Retrive selected asset in the form of Data
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await saveFileService.saveFile(id: fileId, data: data)
                } else {
                    debugPrint("🧨", "Could not upload photo")
                    DispatchQueue.main.async {
                        fileUploadFailedMessage = "The file you selected to upload failed: loadTransferable"
                        showUploadError = true
                    }
                }
            }
        }
        .onChange(of: firebaseService.fcms, { oldValue, newValue in
            debugPrint("🦁", "fcms: \(newValue)")
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
                .disabled(fileId == nil ? false : true)
            }
        }
        .alert("Upload File", isPresented: $saveFileService.showError) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Error: \(saveFileService.fileUploadFailedMessage)")
        }
        .alert("Upload File", isPresented: $saveFileService.showSuccess) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Succeeded")
        }
        .alert("Upload File", isPresented: $showUploadError) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text(fileUploadFailedMessage)
        }
        .onChange(of: notificationManager.fcmToken, { oldValue, newValue in
            if newValue.isEmpty == false {
                debugPrint("🛎️", "Set fcmToken")
                // check fcms for value
                Task {
                    if let items = await firebaseService.readFCMs() {
                        let result = items.contains { item in
                            item.fcm == newValue
                        }
                        if result == false {
                            await firebaseService.writeFCM(fcm: newValue)
                        }
                    }
                }
            }
        })
    }
}

#Preview {
    HomeView()
}
