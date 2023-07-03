//
//  HomeTop.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/01.
//

import SwiftUI

struct HomeTop: View {
    @Binding var firstDateOfDisplayedMonth: Date
    @Binding var selectedDate: Date?
    @Binding var isPresentedCalendar: Bool

    private let calendar = Calendar.current
    let motivationalPhrases: [String] = [
        "一日一日を、文字にしてみましょう",
        "日々を描く、それはあなただけの物語",
        "日記は自分との対話",
        "過去を振り返ることは、未来につながります",
        "あなたの日々は、宝物です",
        "今日を記録することは、明日への一歩",
        "感じたこと、すべて大切に",
        "日記はあなたの生活を彩ります"
    ]
    let praisePhrases: [String] = [
        "日々の記録はあなたの成長です",
        "一日を振り返るのは素敵な習慣です",
        "あなたの言葉が日々を彩ります",
        "今日も、あなたの物語が進みましたね",
        "素晴らしい！あなたの一日を祝いましょう",
        "日々を綴るあなたが素晴らしいです"
    ]

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            callToActionView

            VStack(spacing: 8) {
                Text("Monthly Diaries")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                displayingMonth
            }
        }
        .sheet(isPresented: $isPresentedCalendar) {
            CalendarView(
                calendar: .current,
                selectedDate: firstDateOfDisplayedMonth,
                didSelectDate: { date in
                    selectedDate = date
                },
                didChangeVisibleDateComponents: { dateComponents in
                    if let startOfMonth = dateComponents.date?.startOfMonth {
                        firstDateOfDisplayedMonth = startOfMonth
                    }
                }
            )
            .padding()
            .presentationDetents([.medium])
            .onDisappear{
                selectedDate = nil
            }
        }
    }
}

private extension HomeTop {
    var isDisplayingThisMonth: Bool {
        guard let firstDateOfThisMonth = Date().startOfMonth else { return false }
        return firstDateOfDisplayedMonth == firstDateOfThisMonth
    }

    var consecutiveDays: Int {
        do {
            let consecutiveDays = try Item.calculateConsecutiveDays()
            return consecutiveDays
        } catch {
            return 0
        }
    }

    // MARK: View

    /*
     Patterns

     * today diary
     今日何らかのItemを作成した: 褒める
     今日何も作成していない場合: 日記を書くような訴求　+ 継続日数表示

     (other pattern will be implemented ...)
     */
    @ViewBuilder
    var callToActionView: some View {
        Group {
            if Item.hasTodayItem {
                callToActionContent(
                    title: "Nice！今日は日記を記録できました",
                    subTitle: praisePhrases.randomElement()!,
                    bottomMessage: "今月の日記数: \(Item.thisMonthItemsCount) 件"
                )
            } else {
                callToActionContent(
                    title: "出来事を振り返ってみませんか？",
                    subTitle: motivationalPhrases.randomElement()!,
                    bottomMessage: "現在の継続日数: \(consecutiveDays) 日"
                )
            }
        }
        .padding(.horizontal)
        .frame(height: 100)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()
        }
    }

    func callToActionContent(title: String, subTitle: String, bottomMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
            Text(subTitle)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text(bottomMessage)
                .font(.system(size: 16))
                .padding(.top, 4)
        }
    }

    var displayingMonth: some View {
        HStack(spacing: 8) {
            Button(actionWithHapticFB: {
                moveMonth(.backward)
            }, label: {
                chevronIcon(.backward)
            })


            Button(actionWithHapticFB: {
                isPresentedCalendar = true
            }, label: {
                HStack(spacing: 12) {
                    Text(firstDateOfDisplayedMonth, formatter: dateFormatter)
                        .font(.system(size: 20))

                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: 24)
                }
                .frame(width: 200)
            })

            Button(actionWithHapticFB: {
                moveMonth(.forward)
            }, label: {
                chevronIcon(.forward, disabled: isDisplayingThisMonth)
            })
            .disabled(isDisplayingThisMonth)
        }
        .onSwipe { direction in
            moveMonthWithSwipe(direction)
        }
        .frame(maxWidth: .infinity)
    }

    func chevronIcon(_ direction: Direction, disabled: Bool = false) -> some View {
        var imageName: String
        var xOffset: CGFloat
        switch direction {
        case .forward:
            imageName = "chevron.forward"
            xOffset = 2
        case .backward:
            imageName = "chevron.backward"
            xOffset = -2
        }

        return Circle()
            .foregroundColor(.adaptiveWhite)
            .frame(width: 48)
            .adaptiveShadow()
            .overlay {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(disabled ? .gray : .primary)
                    .frame(width: 12)
                    .offset(x: xOffset)
            }
    }

    // MARK: Action

    func moveMonth(_ direction: Direction) {
        var diff: Int
        switch direction {
        case .forward:
            guard !isDisplayingThisMonth else { return }
            diff = 1
        case .backward:
            diff = -1
        }

        guard let date = calendar.date(byAdding: .month, value: diff, to: firstDateOfDisplayedMonth) else { return }

        self.firstDateOfDisplayedMonth = date
    }

    func moveMonthWithSwipe(_ direction: SwipeDirection) {
        switch direction{
        case .left:
            moveMonth(.forward)
        case .right:
            moveMonth(.backward)
        case .up, .down, .none:
            break
        }
    }
}

#if DEBUG

struct HomeTop_Previews: PreviewProvider {

    static var content: some View {
        HomeTop(
            firstDateOfDisplayedMonth: .constant(Date()),
            selectedDate: .constant(Date()),
            isPresentedCalendar: .constant(false)
        )
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
