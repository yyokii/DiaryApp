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
    @Binding var isPresentedCalendar: Bool

    let scrollViewProxy: ScrollViewProxy
    let illustName = Image.randomIllustName

    init(
        dateInterval: DateInterval,
        selectedDate: Binding<Date?>,
        isPresentedCalendar: Binding<Bool>,
        scrollViewProxy: ScrollViewProxy
    ) {
        /*
         HomeViewでitemsを管理した場合、EnvironmentObjectの更新毎にFetchRequestが発火し、再描画をトリガーに特定のDateでFetchRequestを作成することが難しい。
         別Viewを作成しinitでFetchRequestを作成することで再描画時の表示情報が特定のDateIntervalに紐づくものであることを保証している。
         */
        _items = FetchRequest(fetchRequest: Item.items(of: dateInterval))

        self._selectedDate = selectedDate
        self._isPresentedCalendar = isPresentedCalendar
        self.scrollViewProxy = scrollViewProxy
    }

    var body: some View {
        if items.isEmpty {
            /*
             TODO: 修正したい

             listのコンテンツがあり且つヘッダーがStickyになっている（十分に上にスクロールされている）状態から、emptyもしくはlistが1?に遷移した際に、
             [SwiftUI] Modifying state during view update, this will cause undefined behavior.
             が生じる。

             ScalingHeaderScrollViewの
             self.progress = getCollapseProgress()
             の箇所。
             */
            empty
                .padding(.top, 60)
                .padding(.bottom, UIScreen.contentBottomSpace)
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
            .padding(.top, 12)
            .padding(.bottom, UIScreen.contentBottomSpace)
            .onChange(of: selectedDate, perform: { newValue in
                guard let date = newValue else {
                    return
                }

                if let firstItemOnDate = fetchFirstItem(on: date) {
                    withAnimation {
                        scrollViewProxy.scrollTo(firstItemOnDate.objectID, anchor: .center)
                        isPresentedCalendar = false
                    }
                } else {
                    bannerState.show(of: .warning(message: "No diary for this date"))
                }
            })
        }
    }
}

private extension DiaryList {
    var empty: some View {
        VStack {
            Image(illustName)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding(28)
                .background{
                    Circle()
                        .foregroundColor(.white)
                        .blur(radius: 3)
                }

            Text("「+」ボタンから日記を作成して、\nあなたの経験を振り返りましょう")
                .foregroundColor(.gray)
                .font(.system(size: 16))
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
            ScrollViewReader { proxy in
                DiaryList(
                    dateInterval: .init(start: Date(), end: Date()),
                    selectedDate: .constant(Date()),
                    isPresentedCalendar: .constant(false),
                    scrollViewProxy: proxy
                )
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
