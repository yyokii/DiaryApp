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

    /// lightモードの場合に、白を設定し且つカラーテーマに対応する
    public static let adaptiveBackground = Self {
        $0.userInterfaceStyle == .dark ? .black : .white
    }

    public static let appBlack = hex(0x2C2C2E)

    /*
     primary: 頻繁に仕様される、アプリの基調となる色。
     secondary: 強調したり他と区別するために仕様する色。多様してこの色が目立ちすぎないように注意。
     primary/secondary valiant: dark/light 同系統の色にしたいが、UI要素の違いがある場合にvaliantを作成し色の差異をつける。
     */
    public static let appPrimary = hex(0xda3167)
    public static let appPrimary_100 = hex(0xf9bed3)
    public static let appSecondary = hex(0x31daa4)
    public static let appSecondary_100 = hex(0xe1f9ef)

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
                HStack {
                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.adaptiveBlack)
                        Text("adaptiveBlack")
                    }

                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.adaptiveWhite)
                        Text("adaptiveWhite")
                    }
                }

                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.adaptiveBackground)
                    Text("adaptiveBackground")
                }

                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.placeholderGray)
                    Text("placeholderGray")
                }

                HStack {
                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.appPrimary)
                        Text("appPrimary")
                    }

                    VStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.appSecondary)
                        Text("appSecondary")
                    }
                }


            }
            .shadow(radius: 10)
            .padding(.horizontal)
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
