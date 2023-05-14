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
        if let selectedImage {
            imageViewer(selectedImage)
        } else {
            imagePicker
        }
    }
}

private extension AddPhoto {

    // MARK: View

    func imageViewer(_ image: UIImage) -> some View {
        Image(uiImage: image)
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
                .padding(.top, 8)
                .padding(.trailing, 8)
            })
    }

    var imagePicker: some View {
        PhotosPicker(selection: $selectedPickerItem) {
            ZStack() {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(height: 300)
                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.primary)
            }
        }
        .onChange(of: selectedPickerItem) { pickerItem in
            updateSelectedImage(to: pickerItem)
        }
    }

    // MARK: Action

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
            VStack {
                AddPhoto(selectedImage: .constant(nil))
                AddPhoto(selectedImage: .constant(UIImage(named: "sample")!))
            }
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

