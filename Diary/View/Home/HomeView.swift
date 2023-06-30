//
//  HomeView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/01.
//

import CoreData
import SwiftUI
import ScalingHeaderScrollView

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject private var sceneDelegate: DiaryAppSceneDelegate
    @EnvironmentObject private var bannerState: BannerState

    @State private var firstDateOfDisplayedMonth = Date().startOfMonth!
    @State private var isPresentedCreateDiaryView = false
    @State private var isPresentedCalendar = false
    @State private var selectedDate: Date? = Date()
    @State private var headerScrollProgress: CGFloat = 0

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack() {
                    appInfo
                        .padding(.trailing)
                        .padding(.top, 20)

                    HomeTop(
                        firstDateOfDisplayedMonth: $firstDateOfDisplayedMonth,
                        selectedDate: $selectedDate,
                        isPresentedCalendar: $isPresentedCalendar,
                        headerScrollProgress: headerScrollProgress
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 16) // shadowが切れずに表示される分の領域を確保

                    DiaryList(
                        dateInterval: displayDateInterval,
                        selectedDate: $selectedDate,
                        isPresentedCalendar: $isPresentedCalendar
                    )

                    Spacer()
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
