import Foundation

extension Date {
    static var currentMonthFirstDate: Date {
        guard let currentMonthFirstDate = Calendar.current.date(
            from: Calendar.current.dateComponents([.month, .year], from: .now)
        ) else {
            return .now
        }

        return currentMonthFirstDate
    }
}
