//
//  DiaryTextEditor.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/25.
//

import SwiftUI

struct DiaryTextEditor: View {
    static let textRange = 0...1000

    @Binding var bodyText: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.gray.opacity(0.5)
                .blur(radius: 10)

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $bodyText)
                        .scrollContentBackground(.hidden)
                        .background(Color.adaptiveWhite)
                        .cornerRadius(12)
                        .padding(.top)
                        .padding(.horizontal)

                    ProgressView(
                        "文字数: \(bodyText.count) / \(DiaryTextEditor.textRange.upperBound)",
                        value: Double(bodyText.count),
                        total: Double(DiaryTextEditor.textRange.upperBound)
                    )
                    .accentColor(progressColor)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.adaptiveWhite)
                .cornerRadius(12)
                .padding()
                .border(.red)

                Button(actionWithHapticFB: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("OK")
                }
                .buttonStyle(ActionButtonStyle(backgroundColor: .appRed, isActive: isValidText, size: .small))
                .disabled(!isValidText)

            }
            .padding(.bottom)
        }
        .ignoresSafeArea(.container, edges: [.bottom]) // .container を指定しキーボードを回避
    }
}

private extension DiaryTextEditor {
    var isValidText: Bool {
        DiaryTextEditor.textRange.contains(bodyText.count)
    }

    var progressColor: Color {
        bodyText.count > DiaryTextEditor.textRange.upperBound
        ? .red
        : .adaptiveBlack
    }
}

#if DEBUG

struct DiaryTextEditor_Previews: PreviewProvider {

    static var content: some View {
        VStack {
            DiaryTextEditor(
                bodyText: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s\ndemo\ndemo\ndemo\ndemo\n"),
                isPresented: .constant(true)
            )

            DiaryTextEditor(
                bodyText: .constant(String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s", count: 11)),
                isPresented: .constant(true)
            )
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

