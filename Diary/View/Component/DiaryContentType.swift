//
//  DiaryContentType.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/16.
//

enum DiaryContentType: CaseIterable {
    case text
    case checkList

    var name: String {
        switch self {
        case .text:
            return "テキスト"
        case .checkList:
            return "チェックリスト"
        }
    }
}
