//
//  WelcomeView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/05.
//

import SwiftUI

/*
 1. アプリ全体の機能紹介
 2. 位置情報取得依頼
 3. リマインダー設定
 */
struct WelcomeView: View {
    @EnvironmentObject private var notificationSetting: NotificationSetting
    @EnvironmentObject private var weatherData: WeatherData

    @AppStorage(UserDefaultsKey.hasBeenLaunchedBefore.rawValue)
    private var hasBeenLaunchedBefore: Bool = false
    @State private var selectedPage = 1
    @State private var selectedDate: Date = Date()

    private let maxPageCount = 3

    var body: some View {
        VStack {
            TabView(selection: $selectedPage) {
                Group {
                    appIntroduction
                        .tag(1)
                    requestLocation
                        .tag(2)
                    setReminder
                        .tag(3)
                }
                .contentShape(Rectangle()).gesture(DragGesture()) // スワイプでのページ遷移をしない
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            nextButton
                .padding(.bottom)
        }
    }
}

private extension WelcomeView {

    var nextButton: some View {

        // TODO: refactoring
        Button(actionWithHapticFB: {
            if selectedPage == 2 {
                weatherData.requestLocationAuth()
            }

            if selectedPage == 3 {
                Task {
                    do {
                        try await notificationSetting.setNotification(date: selectedDate)
                    }
                }
            }

            if selectedPage >= maxPageCount {
                hasBeenLaunchedBefore = true
                return
            } else {
                withAnimation {
                    selectedPage += 1
                }
            }
        }) {
            Text("OK")
        }
        .buttonStyle(ActionButtonStyle(size: .medium))
    }

    var appIntroduction: some View {
        VStack(spacing: 40) {
            title("ようこそ！", description: "Shizukuはあなたの経験を振り返るシンプルな日記アプリです")

            featureRow(
                icon: "book",
                color: .orange,
                description: "「Shizuku」は直感的でシンプルな日記アプリです。毎日の出来事を簡単に記録し、特別な瞬間を残しましょう。"
            )
            featureRow(
                icon: "checkmark",
                color: .green,
                description: "日々の習慣の追跡に役立つチェックリスト。目標を視覚化し、毎日の成果を確認しましょう。"
            )
            featureRow(
                icon: "icloud",
                color: .blue,
                description: "iCloudと完全に同期。すべてのデバイスで簡単にアクセス可能です。大切な記録はいつでも安全に保管されます。")

        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
    }

    func featureRow(icon: String, color: Color, description: String) -> some View {
        HStack(spacing: 24) {
            IconWithRoundedBackground(systemName: icon, backgroundColor: color)

            Text(description)
                .foregroundColor(.adaptiveBlack.opacity(0.8))
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func title(_ text: String, description: String) -> some View {
        VStack(spacing: 16) {
            Text(text)
                .bold()
                .font(.system(size: 24))
            Text(description)
                .font(.system(size: 18))
        }
    }

    var requestLocation: some View {
        VStack(spacing: 40) {
            title(
                "位置情報の許可",
                description: "位置情報を許可してよりリッチな日記体験を開始しましょう。"
            )

            HStack(spacing: 24) {
                IconWithRoundedBackground(systemName: "mappin", backgroundColor: .green)

                Text("「Shizuku」では自動的に天気情報を追加します。\n位置情報は天気情報の取得のみに使用されます。いつでも設定を変更することが可能です。")
                    .foregroundColor(.adaptiveBlack.opacity(0.8))
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
    }

    var setReminder: some View {
        VStack(spacing: 40) {
            title(
                "リマインダーの設定",
                description: "日記を書くのを習慣化しましょう。面倒な通知は一切しません"
            )

            HStack {
                IconWithRoundedBackground(systemName: "alarm", backgroundColor: .red)
                Text("面倒な通知は一切しません")
            }

            hourAndMinutePicker
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
    }

    var hourAndMinutePicker: some View {
        DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
            .datePickerStyle(WheelDatePickerStyle())
    }
}

#if DEBUG

struct WelcomeView_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            WelcomeView()
        }
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
