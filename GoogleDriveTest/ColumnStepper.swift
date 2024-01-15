/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

class ColumnStepperEnv: ObservableObject {
    @Published var gridColumns: [GridItem]
    var numColumns: Int
    
    init(gridColumns: [GridItem], numColumns: Int) {
        self.gridColumns = gridColumns
        self.numColumns = numColumns
    }
}

struct ColumnStepper: View {
    @EnvironmentObject var columnStepperEnv: ColumnStepperEnv
    
    let title: String
    let range: ClosedRange<Int>

    init(title: String, range: ClosedRange<Int>) {
        self.title = title
        self.range = range
    }

    var body: some View {
        Stepper(title, value: $columnStepperEnv.numColumns, in: range, step: 1) { item in
            debugPrint("🦁")
            withAnimation { columnStepperEnv.gridColumns = Array(repeating: GridItem(.flexible()), count: columnStepperEnv.numColumns) }
//            if item {
//                Task {
//                    await listFileService.getData(nil)
//                }
//            }
        }
    }
}
