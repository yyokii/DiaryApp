//
//  DiaryApp.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/23.
//

import SwiftUI

@main
struct DiaryApp: App {
    @UIApplicationDelegateAdaptor var delegate: DiaryAppDelegate

    @StateObject private var bannerState = BannerState()
    @StateObject private var coreDataProvider = CoreDataProvider.shared
    @StateObject private var textOptions: TextOptions = .makeUserOptions()
    @StateObject private var notificationSetting: NotificationSetting = NotificationSetting()
    @StateObject private var weatherData = WeatherData()

//    init() {
//        let now = Date()
//        for i in -3 ... 0 {
//            let targetDate = Calendar.current.date(byAdding: .month, value: i, to: now)!
//            let item = Item.makeRandom(date: targetDate)
//            let item2 = Item.makeRandom(date: targetDate)
//            try! item.save()
//        }
//    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(bannerState)
                .environment(\.managedObjectContext, coreDataProvider.container.viewContext)
                .environmentObject(textOptions)
                .environmentObject(notificationSetting)
                .environmentObject(weatherData)
        }
    }
}
