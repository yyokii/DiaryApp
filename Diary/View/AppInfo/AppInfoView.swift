//
//  AppInfoView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/10.
//

import SwiftUI

struct AppInfoView: View {
    @EnvironmentObject private var notificationSetting: NotificationSetting

    @State private var consecutiveDays: Int? = 0
    @State private var diaryCount: Int? = 0
    @State private var isReminderOn = false

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationStack {

            attention
                .padding(.horizontal)
                .padding(.vertical)

            Form {
                Section("日記") {
                    streak
                    totalCount
                    bookMark
                    textOption
                    reminder
                }

                Section("サポート") {

                }
            }
            .navigationTitle("アプリについて")
        }
        .onAppear {
            fetchConsecutiveDays()
            fetchDiaryCount()
        }
    }
}

private extension AppInfoView {

    var isiCloudEnabled: Bool {
        (FileManager.default.ubiquityIdentityToken != nil)
    }

    // MARK: View

    @ViewBuilder
    var attention: some View {
        if !isiCloudEnabled {
            warning(
                title: "iCloudがオフです",
                message: "iCloudがオフのため、アプリを削除したり機種変更するとデータがなくなります。データを引き継げるようにオンにしましょう👋"
            )
        } else {
            connectedToiCloud
        }
    }

    var connectedToiCloud: some View {
        HStack(spacing: 20) {
            IconWithRoundedBackground(
                systemName: "checkmark",
                backgroundColor: .green
            )
            .foregroundColor(.adaptiveWhite)
            .padding(.leading)

            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("iCloud連携済み")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                    Text("iCloudにデータが保存されています。アプリを削除したたり機種変更の際は同じApple IDをご利用下さい。")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 8)
            .padding(.vertical, 4)

        }
        .padding(.vertical, 4)
        .frame(height: 110)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()
        }
    }

    func warning(title: String, message: String) -> some View {
        HStack(spacing: 20) {
            IconWithRoundedBackground(
                systemName: "exclamationmark",
                backgroundColor: .yellow
            )
            .foregroundColor(.adaptiveWhite)
            .padding(.leading)

            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                    Text(message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
            .padding(.vertical, 4)

        }
        .padding(.vertical, 4)
        .frame(height: 110)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()
        }
    }

    var streak: some View {
        HStack {
            rowTitle(symbolName: "flame", iconColor: .orange, title: "現在の継続日数")
            Spacer()
            if let consecutiveDays {
                Text("\(consecutiveDays)日")
            } else {
                Text("データの取得に失敗しました")
                    .font(.system(size: 12))
            }
        }
    }

    var totalCount: some View {
        HStack {
            rowTitle(symbolName: "square.stack", iconColor: .blue, title: "合計")
            Spacer()
            if let diaryCount {
                Text("\(diaryCount)件")
            } else {
                Text("データの取得に失敗しました")
                    .font(.system(size: 12))
            }
        }
    }

    var bookMark: some View {
        NavigationLink {
            BookmarkListView()
        } label: {
            rowTitle(symbolName: "bookmark", iconColor: .cyan, title: "ブックマークした日記")
        }
    }

    var textOption: some View {
        NavigationLink {
            TextOptionsView()
        } label: {
            rowTitle(symbolName: "text.quote", iconColor: .gray, title: "テキストの設定")
        }
    }

    var reminder: some View {
        NavigationLink {
            ReminderSettingView()
        } label: {
            HStack {
                rowTitle(symbolName: "bell", iconColor: .red, title: "通知")
                Spacer()
                Group {
                    if notificationSetting.isSetNotification {
                        Text("オン")
                        Text(notificationSetting.setNotificationDate!, formatter: timeFormatter)
                    } else {
                        Text("オフ")
                    }
                }
                .foregroundColor(.gray)
                .font(.system(size: 14))
            }
        }
    }

    func rowTitle(symbolName: String, iconColor: Color, title: String) -> some View {
        HStack {
            IconWithRoundedBackground(
                systemName: symbolName,
                backgroundColor: iconColor
            )
            .foregroundColor(.adaptiveWhite)
            Text(title)
                .font(.system(size: 14))
        }
    }

    // MARK: Action

    func fetchConsecutiveDays() {
        do {
            let consecutiveDays = try Item.calculateConsecutiveDays()
            self.consecutiveDays = consecutiveDays
        } catch {
            self.consecutiveDays = nil
        }
    }

    func fetchDiaryCount() {
        do {
            let count = try Item.count()
            self.diaryCount = count
        } catch {
            self.diaryCount = nil
        }
    }
}

#if DEBUG

struct AppInfoView_Previews: PreviewProvider {

    static var content: some View {
        AppInfoView()
            .environmentObject(NotificationSetting())
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
