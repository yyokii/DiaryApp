//
//  NotificationSetting.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/12.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationSetting: ObservableObject {

    @Published var isSetNotification: Bool = false
    @Published var setNotificationDate: Date? = nil

    private let notificationService = NotificationService()

    init() {
        Task {
            await updateNotificationState()
        }
    }

    func setNotification(date: Date) async throws {
        let appNotificationSettings = await notificationService.getNotificationSettings()

        switch appNotificationSettings {
        case .notDetermined:
            notificationService.requestAuth()
            notificationService.updateEverydayNotification(date: date)
        case .denied:
            throw NotificationSettingError.requiredPermissionInSettingsApp
        case .authorized, .provisional, .ephemeral:
            notificationService.updateEverydayNotification(date: date)
        @unknown default:
            throw NotificationSettingError.requiredPermissionInSettingsApp
        }

        await updateNotificationState()
    }

    func delete() async {
        notificationService.deleteAllNotification()
        await updateNotificationState()
    }

    private func updateNotificationState() async {
        /**
         端末の通知許可設定と設定済みのローカル通知情報を取得し状態を更新する。

         端末の通知許可がされており、且つローカル通知を設定済みである場合にローカル通知を受け取れる状態。
         */
        let appNotificationSettings = await notificationService.getNotificationSettings()
        let latestScheduledNotificationDate = await notificationService.getLatestScheduledNotificationDate()

        if appNotificationSettings == .authorized,
           latestScheduledNotificationDate != nil {
            isSetNotification = true
            setNotificationDate = latestScheduledNotificationDate
        } else {
            isSetNotification = false
            setNotificationDate = nil
        }
    }
}

public enum NotificationSettingError: Error, LocalizedError {
    case requiredPermissionInSettingsApp // 設定アプリで権限の許諾が必要

    public var errorDescription: String? {
        switch self {
        case .requiredPermissionInSettingsApp:
            return "権限がないため通知設定ができません。"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .requiredPermissionInSettingsApp:
            return "設定アプリより、通知をオンにしてください。"
        }
    }
}

