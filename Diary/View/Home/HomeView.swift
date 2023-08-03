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

    @State private var firstDateOfDisplayedMonth = Date().startOfMonth!
    @State private var isCreateDiaryViewPresented = false
    @State private var isCalendarPresented = false
    @State private var selectedDate: Date? = Date()
    @State private var scrollToItem: Item? = nil

    @Namespace var homeTopID

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .appLanguageLocale
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                // メインコンテンツ
                VStack {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            LazyVStack(pinnedViews: .sectionHeaders) {
                                HomeTopCard()
                                    .padding(.horizontal)
                                    .padding(.top)
                                    .id(homeTopID)

                                diaryListSection
                                    .zIndex(-1) // HomeTopCardのshadowを隠さないため
                            }
                        }
                        .onChange(of: scrollToItem, perform: { newValue in
                            defer {
                                isCalendarPresented = false
                            }

                            guard let scrollToItem else { return }

                            withAnimation {
                                scrollViewProxy.scrollTo(scrollToItem.objectID, anchor: .center)
                            }
                        })
                        .onChange(of: firstDateOfDisplayedMonth, perform: { _ in
                            withAnimation {
                                scrollViewProxy.scrollTo(homeTopID)
                            }
                        })
                        .scrollIndicators(.hidden)
                    }
                }

                FloatingButton(
                    action: {
                        isCreateDiaryViewPresented = true
                    },
                    icon: "plus"
                )
                .padding(.trailing, 10)
                .padding(.bottom, 20)
            }
            .navigationTitle("Diary")
            .toolbarBackground(
                .background,
                for: .navigationBar
            )
            .toolbar {
                navigationToolBar
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
                    .frame(width: 28)
                    .bold()
            }
        }
    }

    var diaryListSection: some View {
        Section(header:
                    MonthSelector(
                        firstDateOfDisplayedMonth: $firstDateOfDisplayedMonth,
                        selectedDate: $selectedDate,
                        isCalendarPresented: $isCalendarPresented
                    )
                        .padding(.vertical, 8)
                        .padding(.bottom, 4)
                        .background {
                            Rectangle()
                                .fill(.background)
                        }
        ) {
            DiaryList(
                dateInterval: displayDateInterval,
                selectedDate: $selectedDate,
                scrollToItem: $scrollToItem
            )
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
