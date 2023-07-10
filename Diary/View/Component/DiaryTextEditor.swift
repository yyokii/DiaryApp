//
//  DiaryTextEditor.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/25.
//

import SwiftUI

struct DiaryTextEditor: View {
    @FocusState var focused: Bool

    @ObservedObject var diaryDataStore: DiaryDataStore

    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            background

            VStack(spacing: 12) {
                textEditor
                    .padding()

                okButton
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(.container, edges: [.bottom]) // .container を指定しキーボードを回避
        .onAppear {
            focused = true
        }
    }
}

private extension DiaryTextEditor {

    var progressColor: Color {
        diaryDataStore.bodyText.count > Item.textRange.upperBound
        ? .red
        : .adaptiveBlack
    }

    var background: some View {
        ZStack {
            Color.appSecondary

            Color.gray.opacity(0.2)
                .blur(radius: 10)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
        }
    }

    var textEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $diaryDataStore.bodyText)
                .focused($focused)
                .scrollContentBackground(.hidden)
                .background(Color.adaptiveWhite)
                .cornerRadius(12)
                .padding(.top)
                .padding(.horizontal)

            ProgressView(
                "文字数: \(diaryDataStore.bodyText.count) / \(Item.textRange.upperBound)",
                value: Double(diaryDataStore.bodyText.count),
                total: Double(Item.textRange.upperBound)
            )
            .accentColor(progressColor)
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.adaptiveWhite)
        .cornerRadius(12)
    }

    var okButton: some View {
        Button(actionWithHapticFB: {
            withAnimation {
                isPresented = false
            }
        }) {
            Text("OK")
        }
        .buttonStyle(ActionButtonStyle(backgroundColor: .appPrimary, isActive: diaryDataStore.validContent, size: .small))
        .disabled(!diaryDataStore.validContent)
    }
}

#if DEBUG

struct DiaryTextEditor_Previews: PreviewProvider {

    static var item: Item {
        let item = Item.makeRandom()
        item.body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s\ndemo\ndemo\ndemo\ndemo\n"
        return item
    }

    static var itemWithLongBody: Item {
        let item = Item.makeRandom()
        item.body = String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget tortor porta erat feugiat dictum s", count:11)
        return item
    }

    static var content: some View {
        VStack {
            DiaryTextEditor(
                diaryDataStore: DiaryDataStore(item: item),
                isPresented: .constant(true)
            )

            DiaryTextEditor(
                diaryDataStore: DiaryDataStore(item: itemWithLongBody),
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

