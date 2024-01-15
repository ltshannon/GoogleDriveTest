//
//  GoogleDriveTestApp.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/8/24.
//

import SwiftUI

@main
struct GoogleDriveTestApp: App {
    @StateObject var columnStepperEnv: ColumnStepperEnv = ColumnStepperEnv(gridColumns: Array(repeating: GridItem(.flexible()), count: 3), numColumns: 3)
    @StateObject var saveFielService = SaveFileService()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(columnStepperEnv)
            .environmentObject(saveFielService)
        }
    }
}
