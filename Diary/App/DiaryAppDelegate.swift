//
//  DiaryAppDelegate.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import UIKit

final class DiaryAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = DiaryAppSceneDelegate.self
        return sceneConfig
    }
}
