//
//  HomeView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/11/24.
//

import SwiftUI
import Dependencies
import GoogleDriveClient

struct HomeView: View {
    @EnvironmentObject var columnStepperEnv: ColumnStepperEnv
    @EnvironmentObject var listFileService: ListFileService
    @Dependency(\.googleDriveClient) var client
//    @ObservedObject var listFileService: ListFileService = ListFileService()
    var fileId: String? = nil
    @State private var isAddingPhoto = false
    @State private var isEditing = false
    
    private var columnsTitle: String {
        columnStepperEnv.gridColumns.count > 1 ? "\(columnStepperEnv.gridColumns.count) Columns" : "1 Column"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                ColumnStepper(title: columnsTitle, range: 1...8)
                    .padding([.leading, .trailing])
            }
            ForEach(listFileService.folderFiles, id: \.self) { item in
                NavigationLink {
                    HomeView(fileId: item.fileId)
                } label: {
                    Text(item.name)
                        .DefaultTextButtonStyle()
                }
            }
            ScrollView {
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
            }
            .refreshable {
                Task {
                    await listFileService.getData(fileId != nil ? fileId : nil)
                }
            }
        }
        .task {
            await listFileService.getData(fileId != nil ? fileId : nil)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
                .disabled(fileId == nil ? false : true)
            }
        }
    }
}

#Preview {
    HomeView()
}
