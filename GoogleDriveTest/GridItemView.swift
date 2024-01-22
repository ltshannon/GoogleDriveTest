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
            if file.mimeType == .jpeg {
                if let data = getFileDataService.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                }
            } else if file.mimeType == .pdf {
                VStack {
                    Image(systemName: "doc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.8, height: size * 0.8)
                    Text(file.name)
                }
            } else if file.mimeType == .mp4 {
                VStack {
                    Image(systemName: "movieclapper")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.8, height: size * 0.8)
                    Text(file.name)
                }
            }
        }
        .task {
            await getFileDataService.getData(file: file)
        }
    }
}

