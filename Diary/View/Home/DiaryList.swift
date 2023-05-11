//
//  DiaryList.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/09.
//

import SwiftUI

struct DiaryList: View {
    /*
     > The fetch request and its results use the managed object context stored in the environment, which you can access using the managedObjectContext environment value.
     https://developer.apple.com/documentation/swiftui/fetchrequest

     FetchRequestにより、コンテキストの変化に応じて自動取得を行う
     */
    @FetchRequest private var items: FetchedResults<Item>

    init(date: Date) {
        /*
         HomeViewでitemsを管理した場合、EnvironmentObjectの更新毎にFetchRequestが発火し、再描画をトリガーに特定のDateでFetchRequestを作成することが難しい。
         別Viewを作成しinitでFetchRequestを作成することで再描画時の表示情報が特定のDateに紐づくものであることを保証している。
         */
        _items = FetchRequest(fetchRequest: Item.itemsOfMonth(date: date))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(items) { item in
                    NavigationLink {
                        DiaryDetailView(diaryDataStore: .init(item: item))
                    } label: {
                        DiaryItem(item: item)
                    }
                    .padding(.horizontal, 30)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical)
        }
    }
}
