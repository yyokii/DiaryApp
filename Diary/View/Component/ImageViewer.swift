//
//  ImageViewer.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/13.
//

import SwiftUI

/*
 https://github.com/fuzzzlove/swiftui-image-viewer
 */
public struct ImageViewer: View {

    private let image: Image

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    @State private var offset: CGPoint = .zero
    @State private var lastTranslation: CGSize = .zero

    public init(image: Image) {
        self.image = image
    }

    public init(image: UIImage) {
        self.image = Image(uiImage: image)
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(x: offset.x, y: offset.y)
                    .gesture(makeDragGesture(size: proxy.size))
                    .gesture(makeMagnificationGesture(size: proxy.size))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func makeMagnificationGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value

                // To minimize jittering
                if abs(1 - delta) > 0.01 {
                    scale *= delta
                }
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1 {
                    withAnimation {
                        scale = 1
                    }
                }
                adjustMaxOffset(size: size)
            }
    }

    private func makeDragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let diff = CGPoint(
                    x: value.translation.width - lastTranslation.width,
                    y: value.translation.height - lastTranslation.height
                )
                offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
                lastTranslation = value.translation
            }
            .onEnded { _ in
                adjustMaxOffset(size: size)
            }
    }

    /*
     画像がViewの範囲に収まるようにする
     画像が十分に大きい場合にはそのまま
     */
    private func adjustMaxOffset(size: CGSize) {
        let maxOffsetX = (size.width * (scale - 1)) / 2 // 初期は0
        let maxOffsetY = (size.height * (scale - 1)) / 2

        var newOffsetX = offset.x
        var newOffsetY = offset.y

        if abs(newOffsetX) > maxOffsetX {
            newOffsetX = maxOffsetX * (abs(newOffsetX) / newOffsetX)
        }
        if abs(newOffsetY) > maxOffsetY {
            newOffsetY = maxOffsetY * (abs(newOffsetY) / newOffsetY)
        }

        let newOffset = CGPoint(x: newOffsetX, y: newOffsetY)
        if newOffset != offset {
            withAnimation {
                offset = newOffset
            }
        }
        self.lastTranslation = .zero
    }
}

#if DEBUG

struct ImageViewer_Previews: PreviewProvider {

    static var image: Image {
        Image("sample")
    }

    static var content: some View {
        ImageViewer(image: image)
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
