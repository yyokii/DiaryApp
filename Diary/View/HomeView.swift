//
//  HomeView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/01.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var diaryDataStore = DiaryDataStore()

    @State var items: [Item] = []
    @State var firstDateOfDisplayedMonth = Date().startOfMonth!

    private let calendar = Calendar.current

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack() {
                    settings
                        .padding(.horizontal, 30)
                    displayingMonth
                    diaryList
                }

                FloatingButton(action: {
                    // Perform some action here...
                }, icon: "plus")
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear{
            fetchItemsForMonth(date: firstDateOfDisplayedMonth)
        }
    }

}

private extension HomeView {
    var isDisplayingThisMonth: Bool {
        guard let firstDateOfThisMonth = Date().startOfMonth else { return false }
        return firstDateOfDisplayedMonth == firstDateOfThisMonth
    }

    var settings: some View {
        HStack {
            Spacer()
            Button {
                // TODO: 遷移先
            } label: {
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.primary)
                    .frame(width: 24)
            }
        }
    }

    var displayingMonth: some View {
        HStack {
            Button {
                moveMonth(.backward)
            } label: {
                chevronIcon(.backward)
            }

            Text(firstDateOfDisplayedMonth, formatter: dateFormatter)
                .foregroundColor(.gray)
                .frame(width: 175)

            Button {
                moveMonth(.forward)
            } label: {
                chevronIcon(.forward, disabled: isDisplayingThisMonth)
            }
            .disabled(isDisplayingThisMonth)
        }
    }

    var diaryList: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(items) { item in
                    DiaryItem(item: item)
                        .padding(.horizontal, 30)
                }
            }
            .padding(.top, 10)
        }
    }

    func chevronIcon(_ direction: Direction, disabled: Bool = false) -> some View {
        var imageName: String
        switch direction {
        case .forward:
            imageName = "chevron.forward"
        case .backward:
            imageName = "chevron.backward"
        }

        return Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .foregroundColor(disabled ? .gray : .primary)
            .frame(width: 12)
    }

    func moveMonth(_ direction: Direction) {
        var diff: Int
        switch direction {
        case .forward:
            diff = 1
        case .backward:
            diff = -1
        }

        guard let date = calendar.date(byAdding: .month, value: diff, to: firstDateOfDisplayedMonth) else { return }

        self.firstDateOfDisplayedMonth = date
        fetchItemsForMonth(date: date)
    }

    func fetchItemsForMonth(date: Date) {
        do {
            let itemsOfMonth: [Item] = try Item.itemsOfMonth(date: date)
            self.items = itemsOfMonth
        } catch {
            // エラー処理
        }
    }
}
