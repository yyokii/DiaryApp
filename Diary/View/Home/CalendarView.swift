//
//  CalendarView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/22.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {

    let calendar: Calendar
    let items: [Item]

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

        dateSelection.setSelected(Calendar.current.dateComponents(in: .current, from: Date()), animated: false)

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.items = items
    }

    func makeCoordinator() -> Coordinator {
        Self.Coordinator(parent: self, items: items)
    }
}

// MARK: Coordinator

extension CalendarView {
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

        private let parent: CalendarView

        var items: [Item]

        init(
            parent: CalendarView,
            items: [Item]
        ) {
            self.parent = parent
            self.items = items
        }

        func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents
        ) -> UICalendarView.Decoration? {
            let date = dateComponents.date!
            let hasDiaryItem = items.contains(where: { item in
                if let itemDate = item.date {
                    return parent.calendar.isDate(itemDate, inSameDayAs: date)
                } else {
                    return false
                }
            })

            if hasDiaryItem {
                let image = UIImage(systemName: "circle.fill")
                return .image(image, color: .cyan)
            } else {
                return nil
            }
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
