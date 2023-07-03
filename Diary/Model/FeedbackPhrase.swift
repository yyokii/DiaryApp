//
//  FeedbackPhrase.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/03.
//

import Foundation

final class FeedbackPhrase {

    private let motivationalPhrases: [String] = [
        "一日一日を、文字にしてみましょう",
        "日々を描く、それはあなただけの物語です",
        "日記は自分との対話です",
        "過去を振り返ることは、未来につながります",
        "あなたの日々は、宝物です",
        "今日を記録することは、明日への一歩",
        "感じたこと、すべて大切に",
        "日記はあなたの生活を彩ります"
    ]
    private let praisePhrases: [String] = [
        "日々の記録はあなたの成長です",
        "一日を振り返るのは素敵な習慣です",
        "あなたの言葉が日々を彩ります",
        "今日も、あなたの物語が進みましたね",
        "素晴らしい！あなたの一日を祝いましょう",
        "日々を綴るあなたが素晴らしいです"
    ]
    let motivationalPhrase: String
    let praisePhrase: String

    init() {
        self.motivationalPhrase = motivationalPhrases.randomElement()!
        self.praisePhrase = praisePhrases.randomElement()!
    }
}
