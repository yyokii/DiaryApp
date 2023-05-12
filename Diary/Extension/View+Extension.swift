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
     部分的にradiusをつける
     https://stackoverflow.com/a/58606176/9015472
     */
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
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

