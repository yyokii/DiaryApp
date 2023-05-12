//
//  NotificationService.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/26.
//

import UserNotifications

struct NotificationService {

    let notificationCenter = UNUserNotificationCenter.current()

    func requestAuth() {
        notificationCenter.requestAuthorization(options: [.alert, .badge]) { success, error in
            if error != nil {
                print("🚨 requestAuthorization error：\(String(describing: error?.localizedDescription))")
                return
            }
        }
    }

    func getLatestScheduledNotificationDate() async -> Date? {
        return await withCheckedContinuation { continuation in
            notificationCenter.getPendingNotificationRequests { requests in
                guard !requests.isEmpty else {
                    return continuation.resume(returning: nil)
                }

                if let trigger = requests.first?.trigger as? UNCalendarNotificationTrigger,
                   let nextTriggerDate = trigger.nextTriggerDate() {
                    return continuation.resume(returning: nextTriggerDate)
                } else {
                    return continuation.resume(returning: nil)
                }
            }
        }
    }

    func needToSetupInSettingsApp() async -> Bool {
        return await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .denied:
                    return continuation.resume(returning: true)
                case .notDetermined:
                    requestAuth()
                    return continuation.resume(returning: false)
                case .authorized, .ephemeral, .provisional:
                    return continuation.resume(returning: false)
                @unknown default:
                    return continuation.resume(returning: false)
                }
            }
        }
    }

    func getNotificationSettings() async -> UNAuthorizationStatus  {
        return await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                return continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    func updateEverydayNotification(date: Date) {
//        assert(0 <= hour && hour <= 24 && 0 <= minute && minute <= 59)
        deleteAllNotification()

        let content = UNMutableNotificationContent()
        content.title = "Hi, your diary time👋"
        content.subtitle = "look back today"
        content.body = "Write diary, make your life beautiful"
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        let scheduledDate = DateComponents(
            calendar: calendar,
            timeZone: TimeZone.current,
            hour: hour,
            minute: minute
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: scheduledDate, repeats: true)
        let request = UNNotificationRequest(identifier: "com.devtechie.notification", content: content, trigger: trigger)

        notificationCenter.add(request)
    }

    func deleteAllNotification() {
        // 通知センターにある配信済みのものを削除
        notificationCenter.removeAllDeliveredNotifications()
        // 配信予定のものを削除
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
