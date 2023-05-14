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

    private let calendar = Calendar.current

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12) {
                    appInfo
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                    displayingMonth
                    DiaryList(date: firstDateOfDisplayedMonth)
                }

                FloatingButton(
                    action: {
                        isPresentedCreateDiaryView = true
                    },
                    icon: "plus"
                )
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .onSwipe { direction in
                moveMonthWithSwipe(direction)
            }
        }
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
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    var displayingMonth: some View {
        HStack {
            Button(action: {
                moveMonth(.backward)
            }, label: {
                chevronIcon(.backward)
            })

            Text(firstDateOfDisplayedMonth, formatter: dateFormatter)
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .frame(width: 175)

            Button(action: {
                moveMonth(.forward)
            }, label: {
                chevronIcon(.forward, disabled: isDisplayingThisMonth)
            })
            .disabled(isDisplayingThisMonth)
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
