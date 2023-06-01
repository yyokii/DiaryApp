//
//  HomeView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/01.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var sceneDelegate: DiaryAppSceneDelegate
    @EnvironmentObject private var bannerState: BannerState

    @State private var firstDateOfDisplayedMonth = Date().startOfMonth!
    @State private var isPresentedCreateDiaryView = false
    @State private var isPresentedCalendar = false
    @State private var selectedDate: Date? = Date()

    private let calendar = Calendar.current

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 8) {
                    appInfo
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                    displayingMonth
                    DiaryList(
                        dateInterval: displayDateInterval,
                        selectedDate: $selectedDate
                    )
                }

                FloatingButton(
                    action: {
                        isPresentedCreateDiaryView = true
                    },
                    icon: "plus"
                )
                .padding(.trailing, 10)
                .padding(.bottom, 20)
            }
        }
        .tint(.adaptiveBlack)
        .onAppear {
            sceneDelegate.bannerState = bannerState
        }
        .sheet(isPresented: $isPresentedCreateDiaryView) {
            CreateDiaryView()
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

private extension HomeView {
    var isDisplayingThisMonth: Bool {
        guard let firstDateOfThisMonth = Date().startOfMonth else { return false }
        return firstDateOfDisplayedMonth == firstDateOfThisMonth
    }

    var displayDateInterval: DateInterval {
        .init(
            start: firstDateOfDisplayedMonth,
            end: firstDateOfDisplayedMonth.endOfMonth!
        )
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

#if DEBUG

struct Home_Previews: PreviewProvider {

    static var content: some View {
        HomeView()
        .environmentObject(DiaryAppSceneDelegate())
        .environmentObject(BannerState())
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
