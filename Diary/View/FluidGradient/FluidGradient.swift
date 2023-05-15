//
//  FluidGradient.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/16.
//

import SwiftUI

public struct FluidGradient: View {
    private var blobs: [Color]
    private var highlights: [Color]
    private var blur: CGFloat
    private var speed: CGFloat

    @State private var blurValue: CGFloat = 0.0

    public init(
        blobs: [Color],
        highlights: [Color] = [],
        blur: CGFloat = 0.75,
        speed: CGFloat = 1
    ) {
        self.blobs = blobs
        self.highlights = highlights
        self.blur = blur
        self.speed = speed
    }

    public var body: some View {
        BaseRepresentable(
            blobs: blobs,
            highlights: highlights,
            blurValue: $blurValue,
            speed: speed
        )
        .blur(radius: pow(blurValue, blur))
        .accessibility(hidden: true)
        .clipped()
    }
}

// MARK: - Representable
extension FluidGradient {
    struct BaseRepresentable: UIViewRepresentable {
        var blobs: [Color]
        var highlights: [Color]
        var blurValue: Binding<CGFloat>
        var speed: CGFloat

        func makeView(context: Context) -> FluidGradientView {
            context.coordinator.view
        }

        func updateView(_ view: FluidGradientView, context: Context) {
            context.coordinator.create(blobs: blobs, highlights: highlights)
            DispatchQueue.main.async {
                context.coordinator.update(speed: speed)
            }
        }

        func makeUIView(context: Context) -> FluidGradientView {
            makeView(context: context)
        }

        func updateUIView(_ view: FluidGradientView, context: Context) {
            updateView(view, context: context)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(
                blobs: blobs,
                highlights: highlights,
                blurValue: blurValue,
                speed: speed
            )
        }
    }

    class Coordinator: FluidGradientDelegate {
        var view: FluidGradientView

        private var blobs: [Color]
        private var highlights: [Color]
        private var blurValue: Binding<CGFloat>
        private var speed: CGFloat

        init(
            blobs: [Color],
            highlights: [Color],
            blurValue: Binding<CGFloat>,
            speed: CGFloat
        ) {
            self.blobs = blobs
            self.highlights = highlights
            self.blurValue = blurValue
            self.speed = speed
            self.view = FluidGradientView(
                blobs: blobs,
                highlights: highlights,
                speed: speed
            )
            self.view.delegate = self
        }

        /// Create blobs and highlights
        func create(blobs: [Color], highlights: [Color]) {
            guard blobs != self.blobs || highlights != self.highlights else { return }
            self.blobs = blobs
            self.highlights = highlights
            
            view.create(blobs, layer: view.baseLayer)
            view.create(highlights, layer: view.highlightLayer)
        }

        /// Update speed
        func update(speed: CGFloat) {
            guard speed != self.speed else { return }
            self.speed = speed
            view.update(speed: speed)
        }

        func updateBlur(_ value: CGFloat) {
            blurValue.wrappedValue = value
        }
    }
}

#if DEBUG

struct FluidGradient_Previews: PreviewProvider {

    static var content: some View {
        FluidGradient(
            blobs: [.red, .blue, .yellow, .green],
            highlights:  [.red, .blue, .yellow, .green]
        )
    }

    static var previews: some View {
        Group {
            content
                .environment(\.colorScheme, .light)
        }
    }
}

#endif
