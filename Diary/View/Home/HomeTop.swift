//
//  HomeTop.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/01.
//

import SwiftUI

struct HomeTop: View {
    var topEdge: CGFloat
    var maxHeight: CGFloat

    @Binding var offset: CGFloat
    @Binding var firstDateOfDisplayedMonth: Date
    @Binding var selectedDate: Date?

    @State private var isPresentedCalendar = false
    private let calendar = Calendar.current

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

//            appInfo
//                .padding(.horizontal, 32)
//                .padding(.top, 12)
//
//            callToActionView
//                .padding(.horizontal, 32)

            Text("Monthly Diaries")
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
                .padding(.horizontal)
                .padding(.top, 20)
            displayingMonth
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
        .padding(.horizontal)
        .opacity(getOpacity())
    }

    func getOpacity() -> CGFloat {
        if offset >= 0 {
            // 下にスクロールする際は常に表示
            return 1
        } else {
            // 上にスクロールする際はだんだん透明化させる
            let progress = -offset / 100
            let opacity = max(1 - progress, 0)
            return opacity
        }
    }
}

private extension HomeTop {
    var isDisplayingThisMonth: Bool {
        guard let firstDateOfThisMonth = Date().startOfMonth else { return false }
        return firstDateOfDisplayedMonth == firstDateOfThisMonth
    }

    var appInfo: some View {
        HStack {
            Spacer()

            NavigationLink {
                AppInfoView()
            } label: {
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.primary)
                    .frame(width: 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    /*
     今日の投稿がまだの場合: 今日のを書くような表示
     今日の投稿がありで且つ他のエラーがある場合: 褒める + エラー共有
     今日の投稿がありで且つ他のエラーがない場合: 褒める + 継続日数表示
     */
    var callToActionView: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Hi!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                Text("lets write today diary")
                    .foregroundColor(.gray)
                Text("diary make you happy")
                    .padding(.top, 4)
            }
            .padding(.horizontal)
        }
        .frame(height: 100)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()

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
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
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
