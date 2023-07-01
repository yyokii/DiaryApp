//
//  CheckListContent.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/28.
//

import SwiftUI

struct CheckListContent: View {

    let item: CheckListItem
    let isChecked: Bool

    var body: some View {
        HStack {
            Text(item.title ?? "no title")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: isChecked ? "checkmark.square" : "square")
                .font(.system(size: 28))
                .foregroundColor(.green)
        }
    }
}

#if DEBUG

struct CheckListContent_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            VStack {
                CheckListContent(item: .makeRandom(), isChecked: true)
                CheckListContent(item: .makeRandom(), isChecked: false)
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
