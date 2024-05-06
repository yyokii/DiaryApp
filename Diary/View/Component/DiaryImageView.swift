//
//  DiaryImageView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import PhotosUI
import SwiftUI

/**
 日記用画像の閲覧、設定が可能なView

 画像未設定: ボタン
 画像設定あり; 画像  +  xアイコン
 */
struct DiaryImageView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedPickerItem: PhotosPickerItem?

    private let resizeImageSize: CGSize = .init(width: 300, height: 300)
    private let imageHeight: CGFloat = 200

    var body: some View {
            if let image = selectedImage {
                imageViewer(image)
                    .overlay(alignment: .topTrailing, content: {
                        XButton {
                            self.selectedImage = nil
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                    })
            } else {
                imagePicker
            }
    }
}

private extension DiaryImageView {

    // MARK: View

    func imageViewer(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
    }

    var imagePicker: some View {
        PhotosPicker(selection: $selectedPickerItem) {
            HStack {
                Image(systemName: "photo")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptiveBlack)
                Text("画像を設定")
                    .font(.system(size: 12))
                    .foregroundColor(.adaptiveBlack)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.appSecondary)
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
               let resizedImage = uiImage.resizeImage(to: resizeImageSize),
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
    private static let sampleImage = UIImage(named: "sample")!

    static var content: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    DiaryImageView(
                        selectedImage: .constant(nil)
                    )
                    Text("画像設定なし")
                }

                VStack {
                    DiaryImageView(
                        selectedImage: .constant(sampleImage)
                    )
                    Text("画像設定あり")
                }
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

