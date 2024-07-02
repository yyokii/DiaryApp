import Foundation

public extension Date {
    var currentCalendar: Calendar { Calendar.current }

    var startOfMonth: Date? {
        return currentCalendar.dateInterval(of: .month, for: self)?.start
    }

    var endOfMonth: Date? {
        guard let nextMonthFirstDay = currentCalendar.dateInterval(of: .month, for: self)?.end else {
            return nil
        }
        return nextMonthFirstDay.addingTimeInterval(-1)
    }

    static var currentMonthInterval: DateInterval? {
        let currentCalendar = Calendar.current
        let now: Date = .now
        guard let startOfMonth = currentCalendar.dateInterval(of: .month, for: now)?.start,
              let endOfMonth = now.endOfMonth else {
            return nil
        }
        return DateInterval(start: startOfMonth, end: endOfMonth)
    }
}
