//
//  AppInfoView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/10.
//

import SwiftUI

struct AppInfoView: View {

    var body: some View {
        NavigationStack {
            Form {
                Section("日記") {
                    streak
                    totalCount
                    bookMark
                    textOption
                }

                Section("サポート") {

                }
            }
            .navigationTitle("アプリについて")
        }
    }
}

private extension AppInfoView {

    // MARK: View

    var streak: some View {
        NavigationLink("継続日数") {
            TextOptionsView()
        }
    }

    var totalCount: some View {
        NavigationLink("合計") {
            TextOptionsView()
        }
    }

    var textOption: some View {
        NavigationLink("テキストの設定") {
            TextOptionsView()
        }
    }

    var bookMark: some View {
        NavigationLink("ブックマークした日記") {
            BookmarkListView()
        }
    }
    
    // MARK: Action
}

#if DEBUG

struct AppInfoView_Previews: PreviewProvider {

    static var content: some View {
        AppInfoView()
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
