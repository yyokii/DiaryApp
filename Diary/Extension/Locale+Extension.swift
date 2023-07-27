//
//  Locale+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/05.
//

import Foundation

extension Locale {
    /*
     https://qiita.com/uhooi/items/a9c9d8b923005028ce4e
     */
    static var appLanguageLocale: Locale {
        if let languageCode = Locale.preferredLanguages.first {
            return Locale(identifier: languageCode)
        } else {
            return Locale.current
        }
    }

    static let appLocaleFullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = .appLanguageLocale
        return formatter
    }()
}
