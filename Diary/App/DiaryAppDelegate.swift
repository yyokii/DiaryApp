//
//  DiaryAppDelegate.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import UIKit

import FirebaseCore

final class DiaryAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
      FirebaseApp.configure()

      return true
    }

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
