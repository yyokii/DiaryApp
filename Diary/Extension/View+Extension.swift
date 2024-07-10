//
//  View+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/30.
//

import SwiftUI

extension View {
    func invalidInput() -> some View {
        self.foregroundColor(.red)
    }

    @MainActor
    func textOption(_ option: TextOptions) -> some View {
        self
            .font(.system(size: option.fontSize))
            .lineSpacing(option.lineSpacing)
    }

    /**
     Animate when view appear
     */
    func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }

    /**
     部分的にradiusをつける
     https://stackoverflow.com/a/58606176/9015472
     */
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }

    /**
     Adds an action to perform when a swipe action occurs.
     */
    func onSwipe(minimumDistance: CGFloat, perform action: @escaping ((SwipeDirection) -> Void)) -> some View {
        self
            .gesture(
                DragGesture(minimumDistance: minimumDistance, coordinateSpace: .global)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height

                        var direction: SwipeDirection
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            direction = horizontalAmount < 0 ? .left : .right
                        } else {
                            direction = verticalAmount < 0 ? .up : .down
                        }

                        action(direction)
                    }
            )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

enum SwipeDirection {
    case left, right, up, down
}

