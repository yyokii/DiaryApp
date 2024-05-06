//
//  DiaryTextEditor.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/25.
//

import SwiftUI

struct DiaryTextEditor: View {
    @EnvironmentObject private var textOptions: TextOptions

    @Binding var bodyText: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing, spacing: 12) {
                TextEditor(text: $bodyText)
                    .frame(height: 300)
                    .multilineTextAlignment(.leading)
                    .textOption(textOptions)
                    .scrollIndicators(.visible)

                Text("文字数: \(bodyText.count) / \(Item.textRange.upperBound)")
                    .foregroundStyle(isOverMaxBodyText ? .red : .adaptiveBlack)
                    .foregroundColor(.gray)
            }

            if bodyText.isEmpty {
                Text("日記の本文") .foregroundColor(Color(uiColor: .placeholderText))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .allowsHitTesting(false)
            }
        }
    }
}

private extension DiaryTextEditor {
    var isOverMaxBodyText: Bool {
        bodyText.count > Item.textRange.upperBound
    }
}

#if DEBUG

struct DiaryTextEditor_Previews: PreviewProvider {
    @State static var bodyTextEmpty = ""

    @State static var bodyText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s\ndemo\ndemo\ndemo\ndemo\n"

    @State static var bodyLongText = String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s", count:11)

    static var content: some View {
        ScrollView {
            VStack {
                DiaryTextEditor(
                    bodyText: $bodyTextEmpty
                )

                DiaryTextEditor(
                    bodyText: $bodyText
                )

                DiaryTextEditor(
                    bodyText: $bodyLongText
                )
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
        .environmentObject(TextOptions.preview)
    }
}

#endif

