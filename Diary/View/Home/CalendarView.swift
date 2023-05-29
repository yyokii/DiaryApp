//
//  CalendarView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/22.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {

    let calendar: Calendar

    let selectedDate: Date
    let didSelectDate: (Date) -> Void
    let didChangeVisibleDateComponents: (DateComponents) -> Void

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = self.calendar

        let calendarStartDate = DateComponents(calendar: self.calendar, year: 2014, month: 9, day: 1).date!
        let calendarViewDateRange = DateInterval(start: calendarStartDate, end: Date())
        view.availableDateRange = calendarViewDateRange

        // Viewの表示サイズを規定サイズより変更可能にするためのワークアラウンド
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        view.delegate = context.coordinator

        dateSelection.setSelected(Calendar.current.dateComponents(in: .current, from: selectedDate), animated: false)

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Self.Coordinator(parent: self)
    }
}

// MARK: Coordinator

extension CalendarView {
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

        private let parent: CalendarView

        init(parent: CalendarView) {
            self.parent = parent
        }

        // MARK: Delegate

        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            parent.didChangeVisibleDateComponents(calendarView.visibleDateComponents)
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.didSelectDate(date)
            }
        }
    }
}
