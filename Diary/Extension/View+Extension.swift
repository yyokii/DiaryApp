//
//  View+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/30.
//

import SwiftUI

class TextOptions: ObservableObject {
    @Published var fontSize: CGFloat
    @Published var lineSpacing: CGFloat

    static let defaultFontSize: CGFloat = 12
    static let defaultLineSpacing: CGFloat = 4

    init(fontSize: CGFloat, lineSpacing: CGFloat) {
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
    }

    static func makeUserOptions() -> TextOptions {
        let userDefaults = UserDefaults.standard
        let savedFontSize: Int = userDefaults.integer(forKey: UserDefaultsKey.fontSize.rawValue)
        let savedLineSpacing: Int = userDefaults.integer(forKey: UserDefaultsKey.lineSpacing.rawValue)

        print("📝 savedFontSize: \(savedFontSize)")
        print("📝 savedLineSpacing: \(savedLineSpacing)")

        let fontSize: CGFloat = savedFontSize == 0
        ? defaultFontSize
        : CGFloat(savedFontSize)
        let lineSpacing: CGFloat = savedLineSpacing == 0
        ? defaultLineSpacing
        : CGFloat(savedLineSpacing)

        print("📝 fontSize: \(fontSize)")
        print("📝 lineSpacing: \(lineSpacing)")

        return .init(fontSize: fontSize, lineSpacing: lineSpacing)
    }
}

extension View {
    func invalidInput() -> some View {
        self.foregroundColor(.red)
    }

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

