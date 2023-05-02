//
//  DiaryDataStore.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/01.
//

import Combine
import CoreData
import Foundation

struct MonthlyItem {
    let startDate: Date
    var items: [Item]
}

@MainActor
public class DiaryDataStore: ObservableObject {

    @Published var monthlyItems: [MonthlyItem] = []

    init() {
        // 今月から前の2ヶ月分のデータを取得する
        let now = Date()
        let calendar = Calendar.current

        //        for i in -2...0 {
        //            let targetDate = calendar.date(byAdding: .month, value: i, to: now)!
        //            do {
        //                let itemsOfMonth: [Item] = try Item.itemsOfMonth(date: targetDate)
        //                updateMonthlyItems([.init(startDate: targetDate.startOfMonth!, items: itemsOfMonth)])
        //            } catch {
        //                // エラー処理
        //            }
        //        }
        //
        //

//        for i in -1000 ... 0 {
//            let targetDate = calendar.date(byAdding: .month, value: i, to: now)!
//            let item = Item.makeRandom(date: targetDate)
//            try! item.save()
//        }
    }

    func updateMonthlyItems(_ monthlyItems: [MonthlyItem]) {
        var copiedMonthlyItems = self.monthlyItems
        monthlyItems.forEach { monthlyItem in
            if let index = copiedMonthlyItems.firstIndex(where: { $0.startDate == monthlyItem.startDate }) {
                copiedMonthlyItems[index].items = monthlyItem.items
            } else {
                copiedMonthlyItems.append(monthlyItem)
            }
        }
        self.monthlyItems = copiedMonthlyItems.sorted(by: { $0.startDate < $1.startDate })

    }

    func onChangeDisplayedMonth(firstDayOfTheMonth date: Date) {
        let calendar = Calendar.current

        // すでに前月のデータがある場合は何もしない
        guard let previousMonthStartDate = calendar.date(byAdding: .month, value: -2, to: date)?.startOfMonth,
              monthlyItems.first(where: { $0.startDate == previousMonthStartDate }) == nil else {
            print("🏝️ skip fetch previous data")
            return
        }

        // 前月のデータを追加する
        do {
            print("🏝️ fetch previous data")
            let itemsOfMonth: [Item] = try Item.itemsOfMonth(date: previousMonthStartDate)
            updateMonthlyItems([.init(startDate: previousMonthStartDate, items: itemsOfMonth)])
        } catch {
            // エラー処理
        }
    }
}
