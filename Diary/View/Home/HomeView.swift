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

    // For sticky header
    @State var offset: CGFloat = 0
    var topEdge: CGFloat
    let maxHeight: CGFloat = UIScreen.main.bounds.height / 3.2

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
//        NavigationStack {
//            ZStack {
        ScrollView(.vertical) {
                    VStack(spacing: 12) {
                        GeometryReader { proxy in
                            HomeTop(
                                topEdge: topEdge,
                                maxHeight: maxHeight,
                                offset: $offset,
                                firstDateOfDisplayedMonth: $firstDateOfDisplayedMonth,
                                selectedDate: $selectedDate
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: getHeaderHeight(), alignment: .bottom)
                            .background { Color.blue }

                        }
                        .frame(height: maxHeight)
                        .offset(y: -offset) // fixing at top
                        .zIndex(1)

                        DiaryList(
                            dateInterval: displayDateInterval,
                            selectedDate: $selectedDate
                        )
                        .zIndex(0)
                    }
                    .modifier(OffsetModifier(offset: $offset))

                }
//
//                FloatingButton(
//                    action: {
//                        isPresentedCreateDiaryView = true
//                    },
//                    icon: "plus"
//                )
//                .padding(.trailing, 10)
//                .padding(.bottom, 20)
//            }
//        }
        .coordinateSpace(name: "SCROLL")
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

    func getHeaderHeight() -> CGFloat {
        let topContentHeight = maxHeight + offset
        let isGraterThanMinHeight = topContentHeight > (80 + topEdge)
        let height = isGraterThanMinHeight ? topContentHeight : 80 + topEdge
        return height
    }

    // MARK: View
}

#if DEBUG

struct Home_Previews: PreviewProvider {

    static var content: some View {
        HomeView(topEdge: 40)
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
