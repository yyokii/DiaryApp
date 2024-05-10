//
//  CheckListContent.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/28.
//

import SwiftUI

struct CheckListContent: View {
    @EnvironmentObject private var textOptions: TextOptions
    // Core Dataの変更通知を反映させるためにObservedObjectを設定 https://stackoverflow.com/a/63524550/9015472
    @ObservedObject var item: CheckListItem
    let isChecked: Bool

    var body: some View {
        HStack {
            Text(item.title ?? "no title")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textOption(textOptions)
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .font(.system(size: 26))
                .bold()
                .foregroundColor(.primary)
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
        .environmentObject(TextOptions.preview)
    }
}

#endif
