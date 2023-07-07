//
//  ReminderSettingView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/12.
//

import SwiftUI

struct ReminderSettingView: View {
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var notificationSetting: NotificationSetting

    @State private var selectedDate: Date = Date()
    @State private var showRequestNotificationPermissionAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("日記を書く時間を通知して、習慣にしましょう👋")
                    .font(.system(size: 16))
                hourAndMinutePicker
                    .padding(.top, 50)
                saveButton
                if notificationSetting.isSetNotification {
                    deleteButton
                }
            }
            .padding(20)
        }
        .onAppear {
            if let date = notificationSetting.setNotificationDate {
                selectedDate = date
            }
        }
        .alert(isPresented: $showRequestNotificationPermissionAlert) {
            requestPermissionAlert
        }
        .navigationTitle("通知")
    }
}


private extension ReminderSettingView {

    // MARK: View

    var hourAndMinutePicker: some View {
        DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
            .datePickerStyle(WheelDatePickerStyle())
    }

    var requestPermissionAlert: Alert {
        Alert(
            title: Text("設定アプリで通知をオンにしてください"),
            message: Text("通知をオンにすることで設定できるようになります。"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            )
        )
    }

    var saveButton: some View {
        Button(actionWithHapticFB: {
            save()
        }, label: {
            Text("設定する")
        })
        .buttonStyle(ActionButtonStyle())
    }

    var deleteButton: some View {
        Button(actionWithHapticFB: {
            Task {
                await notificationSetting.delete()
            }
            bannerState.show(of: .success(message: "通知を未設定にしました🗑️"))
        }, label: {
            Text("未設定にする")
        })
        .buttonStyle(ActionButtonStyle(backgroundColor: .red))
    }

    // MARK: Action

    func save() {
        Task {
            do {
                try await notificationSetting.setNotification(date: selectedDate)
                bannerState.show(of: .success(message: "通知を設定しました🎉"))
            } catch NotificationSettingError.requiredPermissionInSettingsApp {
                showRequestNotificationPermissionAlert = true
            } catch {
                bannerState.show(with: error)
            }
        }
    }
}

#if DEBUG

struct ReminderSettingView_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            ReminderSettingView()
                .environmentObject(NotificationSetting())
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


