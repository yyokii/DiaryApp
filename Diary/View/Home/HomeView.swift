//
//  HomeView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/01.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject private var sceneDelegate: DiaryAppSceneDelegate
    @EnvironmentObject private var bannerState: BannerState

    @AppStorage(UserDefaultsKey.hasBeenLaunchedBefore.rawValue)
    private var hasBeenLaunchedBefore: Bool = false

    @State private var isCreateDiaryViewPresented = false
    @State private var isCalendarPresented = false
    @State private var selectedDate: Date? = Date()
    @State private var scrollToItem: Item? = nil
    @State private var diaryListInterval: DateInterval = Date.currentMonthInterval!

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .appLanguageLocale
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // メインコンテンツ
                ZStack(alignment: .topTrailing) {
                    appInfo
                        .padding(.top, 8)
                        .padding(.trailing, 16)
                        .zIndex(200)
                    GeometryReader { proxy in
                        let safeArea = proxy.safeAreaInsets
                        CalendarContainer(
                            selectedMonth: $diaryListInterval.start,
                            safeAreaInsets: safeArea) {
                                VStack {
                                    DiaryList(
                                        dateInterval: diaryListInterval,
                                        scrollToItem: $scrollToItem
                                    )
                                    .frame(width: proxy.size.width - 20)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 10)
                                }
                            }
                            .ignoresSafeArea(.container, edges: .top)
                            .onSwipe(minimumDistance: 28) { direction in
                                print(direction)
                                switch direction {
                                case .left:
                                    moveMonth(.forward)
                                    break
                                case .right:
                                    // 月を戻る
                                    moveMonth(.backward)
                                    break
                                case .up, .down:
                                    break
                                }
                            }
                    }
                }
                FloatingButton {
                    isCreateDiaryViewPresented = true
                }
                .padding(.trailing, 16)
                .padding(.bottom, 20)
            }
        }
        .tint(.adaptiveBlack)
        .onAppear {
            sceneDelegate.bannerState = bannerState
        }
        .sheet(isPresented: $isCreateDiaryViewPresented) {
            CreateDiaryView()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $hasBeenLaunchedBefore.not) {
            WelcomeView()
                .interactiveDismissDisabled()
        }
    }
}

private extension HomeView {
    var card: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.blue.gradient)
            .frame(height: 70)
    }

    func moveMonth(_ direction: Direction) {
        var diff: Int
        switch direction {
        case .forward:
            diff = 1
        case .backward:
            diff = -1
        }

        guard let date = calendar.date(byAdding: .month, value: diff, to: diaryListInterval.start),
              let start = date.startOfMonth,
              let end = date.endOfMonth else { return }

        diaryListInterval = .init(start: start, end: end)
    }

    var appInfo: some View {
        NavigationLink {
            AppInfoView()
        } label: {
            Image(systemName: "gearshape")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.adaptiveWhite)
                .frame(width: 24)
                .bold()
        }
    }

    var navigationToolBar: some View {
        NavigationLink {
            AppInfoView()
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 18))
                .bold()
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
