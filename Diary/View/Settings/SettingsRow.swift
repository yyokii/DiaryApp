//
//  SettingsRow.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/10.
//

import SwiftUI

struct SettingsRow<Content: View>: View {

    private let title: String
    private let content: () -> Content

    init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
            Spacer()
            content()
        }
    }
}

extension SettingsRow {
    enum Mode<T: View> {
        case arrow(_ destination: () -> T)
        case content(_ content: () -> T)

        @ViewBuilder
        var view: some View {
            switch self {
            case .arrow(let destination):
                NavigationLink {
                    destination()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(PlainButtonStyle())
            case .content(content: let content):
                content()
            }
        }
    }
}
