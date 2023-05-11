//
//  BookmarkListView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/11.
//

import SwiftUI

struct BookmarkListView: View {

    @FetchRequest(fetchRequest: Item.bookmarks)
    private var bookmarks: FetchedResults<Item>

    var body: some View {
        NavigationStack {
            VStack() {
                Text("\(bookmarks.count)件")
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(bookmarks) { item in
                            NavigationLink {
                                DiaryDetailView(diaryDataStore: .init(item: item))
                            } label: {
                                DiaryItem(item: item, withYear: true)
                            }
                            .padding(.horizontal, 30)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("ブックマーク")
        }
    }
}

private extension BookmarkListView {

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
            TextOptionsView()
        }
    }

    // MARK: Action
}

#if DEBUG

struct BookmarkListView_Previews: PreviewProvider {

    static var content: some View {
        BookmarkListView()
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
