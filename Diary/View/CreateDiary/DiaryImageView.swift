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

 編集、画像未設定 → ボタン
 編集、画像設定あり　→ 画像 + xアイコン
 閲覧、画像未設定 → 空
 閲覧、画像設定あり → 画像
 */
struct DiaryImageView: View {
    @Binding var selectedImage: UIImage?

    let isEditing: Bool

    @State private var selectedPickerItem: PhotosPickerItem?

    private let resizeImageSize: CGSize = .init(width: 300, height: 300)
    private let imageHeight: CGFloat = 200

    var body: some View {
        if isEditing {
            if let image = selectedImage {
                imageViewer(image)
                    .overlay(alignment: .topTrailing, content: {
                        xButton
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                    })
            } else {
                imagePicker
            }
        } else {
            if let image = selectedImage {
                // 閲覧状態であり且つ画像設定あり → 画像を表示
                imageViewer(image)
            } 
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
                    .font(.system(size: 16))
                    .foregroundColor(.adaptiveBlack)
                Text("画像を設定")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptiveBlack)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.appSecondary)
                    .adaptiveShadow(size: .small)
            }
        }
        .onChange(of: selectedPickerItem) { pickerItem in
            updateSelectedImage(to: pickerItem)
        }
    }

    var xButton: some View {
        Button(action: {
            self.selectedImage = nil
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.palette)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundStyle(
                    Color.adaptiveWhite,
                    Color.adaptiveBlack
                )
        })
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
                        selectedImage: .constant(nil),
                        isEditing: true
                    )
                    Text("編集, 画像設定なし")
                }

                VStack {
                    DiaryImageView(
                        selectedImage: .constant(sampleImage),
                        isEditing: true
                    )
                    Text("編集, 画像設定あり")
                }

                VStack {
                    DiaryImageView(
                        selectedImage: .constant(nil),
                        isEditing: false
                    )
                    Text("（空 View）")
                    Text("閲覧, 画像未設定")
                }

                VStack {
                    DiaryImageView(
                        selectedImage: .constant(sampleImage),
                        isEditing: false
                    )
                    Text("閲覧, 画像設定あり")
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

