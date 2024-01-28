//
//  DisplayFCMsView.swift
//  GoogleDriveTest
//
//  Created by Larry Shannon on 1/23/24.
//

import SwiftUI

struct DisplayFCMsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    
    var body: some View {
        List {
            ForEach(firebaseService.fcms, id: \.self) { item in
                if let name = item.name {
                    Text(name)
                }
                if let date = item.date {
                    Text(Date.formatDate(date: date))
                }
            }
        }
    }
}

#Preview {
    DisplayFCMsView()
}
