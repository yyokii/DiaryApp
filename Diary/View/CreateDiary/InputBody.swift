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
            TextField(
                "思い出 📝（1000文字以内）",
                text: $bodyText,
                axis: .vertical
            )
            .textOption(textOptions)
            .focused($focusedField, equals: .body)
            .frame(height: 250, alignment: .top)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
                    .padding(-5)
            )

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
