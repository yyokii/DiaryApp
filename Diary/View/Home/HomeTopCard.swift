//
//  HomeTopCard.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/01.
//

import SwiftUI

struct HomeTopCard: View {
    @State private var feedbackPhrase = FeedbackPhrase()

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .appLanguageLocale
        return formatter
    }

    var body: some View {
        callToActionView
    }
}

private extension HomeTopCard {
    var consecutiveDays: Int {
        do {
            let consecutiveDays = try Item.calculateConsecutiveDays()
            return consecutiveDays
        } catch {
            return 0
        }
    }

    // MARK: View

    /*
     Patterns

     * today diary
     今日何らかのItemを作成した: 褒める
     今日何も作成していない場合: 日記を書くような訴求　+ 継続日数表示

     (other pattern will be implemented ...)
     */
    @ViewBuilder
    var callToActionView: some View {
        Group {
            if Item.hasTodayItem {
                callToActionContent(
                    title: "Nice！今日は日記を記録できました",
                    subTitle: feedbackPhrase.praisePhrase,
                    bottomMessage: "今月の日記数: \(Item.thisMonthItemsCount) 件"
                )
            } else {
                callToActionContent(
                    title: "出来事を振り返ってみませんか？",
                    subTitle: feedbackPhrase.motivationalPhrase,
                    bottomMessage: "現在の継続日数: \(consecutiveDays) 日"
                )
            }
        }
        .padding(.horizontal)
        .frame(height: 100)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()
        }
    }

    func callToActionContent(title: String, subTitle: String, bottomMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
            Text(subTitle)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text(bottomMessage)
                .font(.system(size: 16))
                .padding(.top, 4)
        }
    }
}

#if DEBUG

struct HomeTop_Previews: PreviewProvider {

    static var content: some View {
        HomeTopCard()
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
