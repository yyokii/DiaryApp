//
//  TextOptions.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/11.
//

import Foundation

@MainActor
final class TextOptions: ObservableObject {
    static let defaultFontSize: CGFloat = 12
    static let defaultLineSpacing: CGFloat = 4
    static let fontSizeRange: ClosedRange<CGFloat> = 8...40
    static let lineSpacingRange: ClosedRange<CGFloat> = 1...20

    @Published var fontSize: CGFloat
    @Published var lineSpacing: CGFloat

    private let userDefault = UserDefaults.standard

    init(fontSize: CGFloat, lineSpacing: CGFloat) {
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
    }

    static func makeUserOptions() -> TextOptions {
        let userDefaults = UserDefaults.standard
        let savedFontSize: Int = userDefaults.integer(forKey: UserDefaultsKey.fontSize.rawValue)
        let savedLineSpacing: Int = userDefaults.integer(forKey: UserDefaultsKey.lineSpacing.rawValue)

        let fontSize: CGFloat = savedFontSize == 0
        ? defaultFontSize
        : CGFloat(savedFontSize)
        let lineSpacing: CGFloat = savedLineSpacing == 0
        ? defaultLineSpacing
        : CGFloat(savedLineSpacing)

        return .init(fontSize: fontSize, lineSpacing: lineSpacing)
    }

    func save(fontSize: CGFloat, lineSpacing: CGFloat) {
        userDefault.set(fontSize, forKey: UserDefaultsKey.fontSize.rawValue)
        userDefault.set(lineSpacing, forKey: UserDefaultsKey.lineSpacing.rawValue)

        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
    }
}

extension TextOptions {
    static var preview: TextOptions {
        .init(
            fontSize: TextOptions.defaultFontSize,
            lineSpacing: TextOptions.defaultLineSpacing
        )
    }
}
