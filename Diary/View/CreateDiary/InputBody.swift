//
//  InputBody.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI

struct InputBody: View {
    static let bodyCount: (min: Int, max:Int) = (1, 1000)

    @EnvironmentObject private var textOptions: TextOptions

    @Binding var bodyText: String
    @FocusState var focusedField: FocusedField?

    var body: some View {

        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                if bodyText.isEmpty {
                    Text("思いで📝")
                        .textOption(textOptions)
                        .foregroundColor(.placeholderGray)
                        .padding(.top, 8)
                        .padding(.leading, 8)
                        .disabled(true)
                }

                TextEditor(text: $bodyText)
                    .textOption(textOptions)
                    .focused($focusedField, equals: .body)
                    .frame(height: 350)
                    .cornerRadius(10)
                    .opacity(bodyText.isEmpty ? 0.25 : 1)
            }

            if bodyText.count > InputBody.bodyCount.max {
                Text("1000文字以内にしましょう（現在 \(bodyText.count) 文字）")
                    .invalidInput()
                    .font(.system(size: 12))
            }
        }
    }
}

#if DEBUG

struct InputBody_Previews: PreviewProvider {

    static let largBody = String(repeating: "あいうえお123abd", count: 100)

    static var content: some View {
        NavigationStack {
            VStack {
                InputBody(bodyText: .constant(""))
                InputBody(bodyText: .constant("あいうえお123abd"))
                InputBody(bodyText: .constant(largBody))
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
