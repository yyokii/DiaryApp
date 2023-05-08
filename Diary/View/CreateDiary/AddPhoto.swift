//
//  AddPhoto.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import PhotosUI
import SwiftUI

struct AddPhoto: View {
    @Binding var selectedImage: UIImage?

    @State private var selectedPickerItem: PhotosPickerItem?

    private let imageSize: CGSize = .init(width: 300, height: 300)

    var body: some View {
        ZStack() {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .topTrailing, content: {
                        Button {
                            self.selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundStyle(.white, .black)
                        }
                        .padding(.top, 4)
                        .padding(.trailing, 4)
                    })
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(height: 300)
            }

            if selectedImage == nil {
                PhotosPicker(selection: $selectedPickerItem) {
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.primary)
                }
            }
        }
        .onChange(of: selectedPickerItem) { pickerItem in
            updateSelectedImage(to: pickerItem)
        }
    }
}

private extension AddPhoto {
    func updateSelectedImage(to pickerItem: PhotosPickerItem?) {
        Task {
            if let data = try? await pickerItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data),
               let resizedImage = uiImage.resizeImage(to: imageSize),
               let rotatedImage = resizedImage.reorientToUp() {
                await MainActor.run(body: {
                    selectedImage = rotatedImage
                })
            }
        }
    }
}

#if DEBUG

struct AddPhoto_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            AddPhoto(selectedImage: .constant(nil))
        }
    }

    static var previews: some View {
        Group {
            content
                .environment(\.colorScheme, .light)
            content
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif

