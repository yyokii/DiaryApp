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

    init(dateInterval: DateInterval) {
        /*
         HomeViewでitemsを管理した場合、EnvironmentObjectの更新毎にFetchRequestが発火し、再描画をトリガーに特定のDateでFetchRequestを作成することが難しい。
         別Viewを作成しinitでFetchRequestを作成することで再描画時の表示情報が特定のDateIntervalに紐づくものであることを保証している。
         */
        _items = FetchRequest(fetchRequest: Item.items(of: dateInterval))
    }

    var body: some View {
        if items.isEmpty {
            empty
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(items) { item in
                        NavigationLink {
                            DiaryDetailView(diaryDataStore: .init(item: item))
                        } label: {
                            DiaryItem(item: item)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

private extension DiaryList {
    var empty: some View {
        VStack(spacing: 20) {
            Image(systemName: "drop")
                .font(.system(size: 24))

            Text("「+」ボタンから日記を作成して、\nあなたの経験を振り返りましょう")
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .multilineTextAlignment(.center)
        .frame(maxHeight: .infinity)
        .offset(y: -70)
    }
}

#if DEBUG

struct DiaryList_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            DiaryList(dateInterval: .init(start: Date(), end: Date()))
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
