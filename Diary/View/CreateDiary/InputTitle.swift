//
//  InputTitle.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI

enum FocusedField {
    case title, body
}

struct InputTitle: View {
    static let titleCount: (min: Int, max:Int) = (1, 10)

    @Binding var title: String
    @FocusState var focusedField: FocusedField?

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if !title.isEmpty {
                Text("タイトル")
                    .foregroundColor(.placeholderGray)
                    .font(.system(size: 14))
            }

            TextField("タイトル（1~10文字）", text: $title)
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: .title)

            if title.count > InputTitle.titleCount.max {
                Text("タイトルは10文字以内で設定しましょう")
                    .invalidInput()
                    .font(.system(size: 12))
            }
        }
        .animation(.easeInOut, value: title)
    }
}

#if DEBUG

struct InputTitle_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            VStack(spacing: 50) {
                InputTitle(title: .constant("あいうえお123abcdefg"))
                InputTitle(title: .constant("あいうえお"))
            }
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


