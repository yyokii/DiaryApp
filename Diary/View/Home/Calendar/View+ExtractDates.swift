//import Foundation
//import SwiftUI
//
//extension View {
//    /// Extracting Dates for the Given Date
//    func extractDates(_ targetDate: Date) -> [Day] {
//        var days: [Day] = []
//        let calendar: Calendar = .current
//
//        guard let range = calendar.range(of: .day, in: .month, for: targetDate)?.compactMap({ value -> Date? in
//            return calendar.date(byAdding: .day, value: value - 1, to: targetDate)
//        }) else {
//            return days
//        }
//
//        guard  let firstDay = range.first, let lastDay = range.last else {
//            return days
//        }
//
//        let formatStyle = Date.FormatStyle(locale: .init(identifier: "en_US_POSIX"), calendar: calendar).day(.twoDigits)
//
//        // 1日の曜日
//        let firstWeekDay = calendar.component(.weekday, from: firstDay)
//        // 月初の当月以外の日にち数
//        let startIgnoredDateCount = max(firstWeekDay - 1, 0)
//
//        // 月初の非活性の日にちを作成
//        for index in Array(0..<startIgnoredDateCount).reversed() {
//            // firstDayから引いて求めるので「-」indexとし、またindexなので -1 をする
//            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: firstDay) else { return days }
//            let shortSymbol = date.formatted(formatStyle)
//
//            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
//        }
//
//        // 当月の日にちを作成
//        range.forEach { date in
//            let shortSymbol = date.formatted(formatStyle)
//            days.append(.init(shortSymbol: shortSymbol, date: date))
//        }
//
//        // 月末の当月以外の日にち数
//        let lastWeekDay = 7 - calendar.component(.weekday, from: lastDay)
//
//        // 月末の非活性の日にちを作成
//        for index in 0..<lastWeekDay {
//            // lastDayに足して求めるので「+」indexとし、またindexなので +1 をする
//            guard let date = calendar.date(byAdding: .day, value: index + 1, to: lastDay) else { return days }
//            let shortSymbol = date.formatted(formatStyle)
//
//            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
//        }
//
//        return days
//    }
//}
