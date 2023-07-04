//
//  Locale+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/05.
//

import Foundation

extension Locale {
    static var appLanguageLocale: Locale {
        if let languageCode = Locale.preferredLanguages.first {
            return Locale(identifier: languageCode)
        } else {
            return Locale.current
        }
    }
}
