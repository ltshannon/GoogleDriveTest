/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct GridItemView: View {
    @ObservedObject var getFileDataService: GetFileDataService = GetFileDataService()
    let size: Double
    let file: MyFile

    var body: some View {
        VStack {
            if let data = getFileDataService.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
        }
        .task {
            await getFileDataService.getData(id: file.fileId)
        }
    }
}

