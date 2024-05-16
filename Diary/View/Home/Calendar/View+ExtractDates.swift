import Foundation
import SwiftUI

extension View {
    /// Extracting Dates for the Given Month
    func extractDates(_ month: Date) -> [Day] {
        var days: [Day] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"

        guard let range = calendar.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return calendar.date(byAdding: .day, value: value - 1, to: month)
        }) else {
            return days
        }

        let firstWeekDay = calendar.component(.weekday, from: range.first!)

        for index in Array(0..<firstWeekDay - 1).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: range.first!) else { return days }
            let shortSymbol = formatter.string(from: date)
            // これでいけないかな
            // let shortSymbol = date.formatted(.dateTime.day())

            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
        }

        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date))
        }

        let lastWeekDay = 7 - calendar.component(.weekday, from: range.last!)

        if lastWeekDay > 0 {
            for index in 0..<lastWeekDay {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: range.last!) else { return days }
                let shortSymbol = formatter.string(from: date)

                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }

        return days
    }
}
