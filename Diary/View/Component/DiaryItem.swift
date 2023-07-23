//
//  DiaryItem.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

struct DiaryItem: View {
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var textOptions: TextOptions

    @ObservedObject var item: Item

    @State private var opacity: Double = 0

    private let isYearDisplayed: Bool
    private let height: CGFloat = 140
    private let cornerRadius: CGFloat = 10
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = .appLanguageLocale
        return formatter
    }()
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = .appLanguageLocale
        return formatter
    }()
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = .appLanguageLocale
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = .appLanguageLocale
        return formatter
    }()

    init(item: Item, withYear: Bool = false) {
        self.item = item
        self.isYearDisplayed = withYear
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()

            HStack(alignment: .top, spacing: 0) {
                diaryDate

                ZStack(alignment: .topTrailing) {
                    diaryContent
                    bookMarkButton
                        .padding(.top, 8)
                        .padding(.trailing, 12)
                }
            }
        }
        .frame(height: height)
        .opacity(opacity)
        .animate(using: .easeInOut(duration: 0.5)) {
            opacity = 1
        }
    }
}

private extension DiaryItem {
    var diaryDate: some View {
        VStack(alignment: .center) {
            Spacer()
            if let date = item.date {
                if isYearDisplayed {
                    Group {
                        Text(date, formatter: yearFormatter)
                        Text(date, formatter: dateFormatter)
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.adaptiveBlack)
                } else {
                    Text(date, formatter: dayFormatter)
                        .bold()
                        .font(.system(size: 32))
                        .foregroundColor(.adaptiveBlack)
                }
                Text(date, formatter: weekdayFormatter)
                    .font(.system(size: isYearDisplayed ? 18 : 20))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .frame(width: 90)
        .background {
            LinearGradient(gradient: Gradient(colors: [.adaptiveWhite, .appSecondary]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(cornerRadius, corners: [.topLeft, .bottomLeft])
        }
    }

    var bookMarkButton: some View {
        Button(actionWithHapticFB: {
            bookMark()
        }, label: {
            Image(systemName: item.isBookmarked ? "bookmark.fill" : "bookmark")
                .resizable()
                .scaledToFit()
                .frame(width: 11)
                .foregroundColor(.adaptiveBlack)
                .padding(8)
                .background {
                    Circle()
                        .foregroundColor(.adaptiveWhite)
                        .frame(width: 48)
                }
        })
    }

    /**
     [表示パターン（優先順位が高い順）]
     画像が設定されている場合：画像を表示
     画像が設定されていない場合：テキストコンテンツを表示
     画像が設定されていない場合 && テキストが空：チェックリストの内容を表示
     */
    @ViewBuilder
    var diaryContent: some View {
        if let imageData = item.imageData,
           let uiImage: UIImage = .init(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()
                .cornerRadius(cornerRadius, corners: [.topRight, .bottomRight])
                .allowsHitTesting(false) // clipはUI上のclipは起こるが内部では画像をそのままのサイズで保持しているため、予期せぬタップ判定をもたらす。それを回避するためのワークアラウンド。 https://stackoverflow.com/questions/63300411/clipped-not-actually-clips-the-image-in-swiftui
        } else if let body = item.body, !body.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(item.title ?? "")
                    .bold()
                    .font(.system(size: 32))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.trailing, 40)

                Text(item.body ?? "")
                    .textOption(textOptions)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text(item.title ?? "")
                    .bold()
                    .font(.system(size: 32))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.trailing, 40)

                VStack(alignment: .leading, spacing: 4) {
                    // 最初の2つぐらい出してあとは省略にする
                    ForEach(Array(item.checkListItemsArray.prefix(2)), id: \.self) { checkListItem in
                        HStack {
                            Image(systemName:"checkmark")
                                .font(.system(size: 12))
                                .foregroundColor(.green)

                            Text(checkListItem.title ?? "no title")
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.trailing)

                if let itemsCount = item.checkListItems?.count,
                   itemsCount >= 2 {
                    Text("合計\(itemsCount)個のチェックリストを達成しました")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
    }

    func bookMark() {
        item.isBookmarked = !item.isBookmarked
        do {
            try item.save()
        } catch {
            bannerState.show(with: error)
        }
    }
}

#if DEBUG

struct DiaryItem_Previews: PreviewProvider {

    static var content: some View {
        VStack{
            DiaryItem(item: .makeRandom())
                .padding(.horizontal)

            DiaryItem(item: .makeRandom(withImage: true))
                .padding(.horizontal)

            DiaryItem(item: .makeWithOnlyCheckList())
                .padding(.horizontal)

            DiaryItem(item: .makeRandom(), withYear: true)
                .padding(.horizontal)
        }
        .environmentObject(TextOptions.preview)
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
