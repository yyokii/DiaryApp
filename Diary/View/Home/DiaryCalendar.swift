//
//  DiaryCalendar.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/22.
//

import SwiftUI

/*
 そこそこ大きいview（Calendarとリスト）を2つscrollなしで積むのは無理がある
 Calendarでの表示は一旦保留
 */

struct DiaryCalendar: View {
    @EnvironmentObject private var bannerState: BannerState

    @FetchRequest private var items: FetchedResults<Item>
    @State private var firstDateOfDisplayedMonth: Date = Date()
    @State private var isPresentedList: Bool = false

    private let calendar = Calendar.current

    init(
        items: FetchRequest<Item>
    ) {
        self._items = items
    }

    var body: some View {
        VStack {
            CalendarView(
                calendar: .current,
                items: items.map {$0},
                didSelectDate: { date in
                    updateList(for: date)
                },
                didChangeVisibleDateComponents: { dateComponents in
                    if let startOfMonth = dateComponents.date?.startOfMonth {
                        firstDateOfDisplayedMonth = startOfMonth
                        fetchItems(by: .init(
                            start: firstDateOfDisplayedMonth,
                            end: firstDateOfDisplayedMonth.endOfMonth!
                        ))
                    }
                }
            )
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $isPresentedList) {
            diaryList
        }
    }
}

private extension DiaryCalendar {
    // TODO: listは他にも存在しているので共通化したい
    @ViewBuilder
    var diaryList: some View {
        if items.isEmpty {
            Text("this is empty")
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(items) { item in
                        NavigationLink {
                            DiaryDetailView(diaryDataStore: .init(item: item))
                        } label: {
                            DiaryItem(item: item)
                        }
                        .id(item.id)
                        .padding(.horizontal, 20)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical)
            }
        }
    }

    // Actions

    func updateList(for selectedDate: Date) {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        if let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) {
            fetchItems(by: .init(start: startOfDay, end: endOfDay))
        } else {
            print("⚠️ Failed to create endOfDay")
        }
    }

    func fetchItems(by dateInterval: DateInterval) {
        let predicate = NSPredicate(
            format: "date >= %@ && date <= %@",
            dateInterval.start as CVarArg,
            dateInterval.end as CVarArg
        )
        items.nsPredicate = predicate
    }
}

#if DEBUG

struct DiaryCalendar_Previews: PreviewProvider {

    static var content: some View {
        ForEach(["iPhone SE (3rd generation)", "iPhone 14 Pro"], id: \.self) { deviceName in

            DiaryCalendar(items: FetchRequest(fetchRequest: Item.thisMonth))
                .environmentObject(BannerState())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
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
