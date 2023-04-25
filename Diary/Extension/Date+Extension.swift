//
//  Date+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/25.
//

import Foundation

public extension Date {
    var currentCalendar: Calendar { Calendar.current }

    var startOfMonth: Date? {
        return currentCalendar.dateInterval(of: .month, for: self)?.start
    }

    var endOfMonth: Date? {
        return currentCalendar.dateInterval(of: .month, for: self)?.end
    }
}
