//
//  Color.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

extension Color {

    /// lightモードの場合に、白を設定し且つカラーテーマに対応する
    public static let adaptiveWhite = Self {
        $0.userInterfaceStyle == .dark ? appBlack : .white
    }

    /// lightモードの場合に、黒を設定し且つカラーテーマに対応する
    public static let adaptiveBlack = Self {
        $0.userInterfaceStyle == .dark ? .white : appBlack
    }

    public static let appBlack = hex(0x2C2C2E)
//    public static let appMain = hex(0x7ed957)
//    public static let appAccent = hex(0x5ce1e6)

    public static func hex(_ hex: UInt) -> Self {
        Self(
            red: Double((hex & 0xff0000) >> 16) / 255,
            green: Double((hex & 0x00ff00) >> 8) / 255,
            blue: Double(hex & 0x0000ff) / 255,
            opacity: 1
        )
    }
}

#if canImport(UIKit)

import UIKit

extension Color {

    public init(dynamicProvider: @escaping (UITraitCollection) -> Color) {
        self = Self(UIColor { UIColor(dynamicProvider($0)) })
    }

    public static let placeholderGray = Color(UIColor.placeholderText)
}

#endif

#if DEBUG

struct DemoColorView_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.adaptiveBlack)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.adaptiveWhite)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.appBlack)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.placeholderGray)
            }
            .shadow(radius: 10)
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
