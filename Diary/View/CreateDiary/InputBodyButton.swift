//
//  InputBodyButton.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI

struct InputBodyButton: View {
    @EnvironmentObject private var textOptions: TextOptions

    @Binding var bodyText: String
    let action: () -> Void

    var body: some View {
        Button(actionWithHapticFB: {
            withAnimation {
                action()
            }
        }) {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: bodyText.isEmpty ? 300 : 0) // テキストがからの場合でのボタンのタップ領域を確保するために設定

                VStack(alignment: .leading) {
                    Text("📝 日記")
                        .textOption(textOptions)
                        .foregroundColor(.placeholderGray)

                    Text(bodyText)                        .foregroundColor(.adaptiveBlack)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                        .multilineTextAlignment(.leading)
                        .textOption(textOptions)
                }
            }
        }
    }
}

#if DEBUG

struct InputBody_Previews: PreviewProvider {

    static let longText = String(repeating: "あいうえお123abd", count: 50)

    static var content: some View {
        NavigationStack {
            VStack {
                InputBodyButton(bodyText: .constant("あいうえお123abd"), action: {})
                InputBodyButton(bodyText: .constant(longText), action: {})
            }
            .environmentObject(TextOptions.preview)
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
