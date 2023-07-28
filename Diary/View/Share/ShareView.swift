//
//  ShareView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/23.
//

import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @EnvironmentObject private var bannerState: BannerState

    let item: Item

    @State private var selectedColor: Color = .white
    @State private var renderedImage: UIImage = UIImage(named: "sample")!
    @State private var contentPattern: ShareContentPattern?
    @State private var isActivityViewPresented = false

    var body: some View {
        ScrollView {
            VStack {
                xButton

                VStack(spacing: 40) {
                    VStack {
                        Image(uiImage: renderedImage)
                        layoutPatternList
                    }

                    ShareCardBackgroundColorList(selectedColor: $selectedColor)

                    HStack(spacing: 30) {
                        shareButton
                        saveButton
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical)
        }
        .sheet(isPresented: $isActivityViewPresented) {
            ActivityView(
                activityItems: [renderedImage],
                applicationActivities: nil
            )
            .presentationDetents([.medium])
        }
        .onAppear {
            contentPattern = availableLayoutPatterns.first
            render()
        }
        .onChange(of: contentPattern) { _ in
            render()
        }
        .onChange(of: selectedColor) { _ in
            render()
        }
    }
}

private extension ShareView {

    var xButton: some View {
        HStack {
            Spacer()
            XButton {
                dismiss()
            }
            .padding(.trailing)
        }
    }

    var availableLayoutPatterns: [ShareContentPattern] {
        var patterns: [ShareContentPattern] = []
        let hasText = (item.body != nil) && !((item.body ?? "").isEmpty)
        let hasChecklist = !item.checkListItemsArray.isEmpty

        if item.imageData != nil, hasText {
            patterns.append(.imageAndText)
        }

        if hasText {
            patterns.append(.text)
        }

        if hasChecklist {
            patterns.append(.checkList)
        }

        return patterns
    }

    @ViewBuilder
    var layoutPatternList: some View {
        if availableLayoutPatterns.count > 1 {
            HStack(spacing: 8) {
                ForEach(availableLayoutPatterns, id: \.self) { pattern in
                    Button(action: {
                        contentPattern = pattern
                    }) {
                        Text(pattern.name)
                            .font(.system(size: 12))
                            .fontWeight(contentPattern == pattern ? .heavy : .medium)
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(contentPattern == pattern ? .blue.opacity(0.3) : .adaptiveWhite)
                            }
                    }
                }
            }
        }
    }

    var shareButton: some View {
        Button(actionWithHapticFB: {
            isActivityViewPresented = true
        }) {
            VStack(spacing: 4) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                    .foregroundColor(.adaptiveWhite)
                    .padding(12)
                    .background {
                        Circle()
                            .fill(Color.adaptiveBlack)
                            .offset(y: 2)
                    }

                Text("Share via...")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptiveBlack)
            }
        }
    }

    var saveButton: some View {
        Button(actionWithHapticFB: {
            saveImage()
        }) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.adaptiveWhite)
                    .padding(12)
                    .background {
                        Circle()
                            .fill(Color.adaptiveBlack)
                    }

                Text("Save")
                    .font(.system(size: 14))
                    .foregroundColor(.adaptiveBlack)
            }
        }
    }

    // MARK: Action

    @MainActor
    func render() {
        guard let contentPattern else {
            return
        }

        let renderer = ImageRenderer(
            content: ShareImageRender(
                backgroundColor: selectedColor,
                item: item,
                contentPattern: contentPattern
            )
        )

        // make sure and use the correct display scale for this device
        renderer.scale = displayScale
        renderer.proposedSize = ProposedViewSize(width: UIScreen.main.bounds.size.width * 0.9, height: nil)

        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
        }
    }

    func saveImage() {
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: renderedImage) {
            bannerState.show(of: .success(message: "保存しました 🎉"))
        }
    }
}

#if DEBUG

struct ShareView_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            ShareView(item: .makeRandom(withImage: true))
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
