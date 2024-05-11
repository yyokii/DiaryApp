//
//  DiaryList.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/09.
//

import SwiftUI

struct DiaryList: View {
    @EnvironmentObject private var bannerState: BannerState

    /*
     > The fetch request and its results use the managed object context stored in the environment, which you can access using the managedObjectContext environment value.
     https://developer.apple.com/documentation/swiftui/fetchrequest

     FetchRequestにより、コンテキストの変化に応じて自動取得を行う
     */
    @FetchRequest private var items: FetchedResults<Item>
    @Binding var selectedDate: Date?
    @Binding var scrollToItem: Item?

    init(
        dateInterval: DateInterval,
        selectedDate: Binding<Date?>,
        scrollToItem: Binding<Item?>
    ) {
        /*
         HomeViewでitemsを管理した場合、EnvironmentObjectの更新毎にFetchRequestが発火し、再描画をトリガーに特定のDateでFetchRequestを作成することが難しい。
         別Viewを作成しinitでFetchRequestを作成することで再描画時の表示情報が特定のDateIntervalに紐づくものであることを保証している。
         */
        _items = FetchRequest(fetchRequest: Item.items(of: dateInterval))

        self._selectedDate = selectedDate
        self._scrollToItem = scrollToItem
    }

    var body: some View {
        if items.isEmpty {
            empty
                .padding(.top, 60)
        } else {
            LazyVStack(spacing: 24) {
                ForEach(items) { item in
                    NavigationLink {
                        DiaryDetailView(diaryDataStore: .init(item: item))
                    } label: {
                        DiaryItem(item: item)
                    }
                    .id(item.objectID)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 200)
            .onChange(of: selectedDate, perform: { newValue in
                guard let date = newValue else {
                    return
                }

                if let firstItemOnDate = fetchFirstItem(on: date) {
                    scrollToItem = firstItemOnDate
                } else {
                    bannerState.show(of: .warning(message: "この日付の日記はありません"))
                }
            })
        }
    }
}

private extension DiaryList {
    var empty: some View {
        VStack {
            Text("「+」ボタンから日記を作成して、\nあなたの経験を振り返りましょう")
                .foregroundColor(.adaptiveBlack)
                .font(.system(size: 20))
                .frame(height: 100)
        }
    }

    func fetchFirstItem(on date: Date) -> Item? {
        // 日付の範囲を設定
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let components = DateComponents(day: 1, second: -1)
        guard let endOfDay = calendar.date(byAdding: components, to: startOfDay) else {
            return nil
        }

        let itemsOnDate = items.filter { item in
            guard let itemDate = item.date else { return false }
            return itemDate >= startOfDay && itemDate <= endOfDay
        }
        return itemsOnDate.first
    }
}

#if DEBUG

struct DiaryList_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            DiaryList(
                dateInterval: .init(start: Date(), end: Date()),
                selectedDate: .constant(Date()),
                scrollToItem: .constant(nil)
            )
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
