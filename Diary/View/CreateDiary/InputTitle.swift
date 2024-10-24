//
//  InputTitle.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI

struct InputTitle: View {
    @Binding var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("タイトル（1~100文字）", text: $title)
                .font(.system(size: 20))
                .multilineTextAlignment(.leading)

            if title.count > Item.titleRange.upperBound {
                Text("タイトルは100文字以内で設定しましょう")
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
                InputTitle(title: .constant(""))
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


