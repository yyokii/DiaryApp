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
        return formatter
    }()
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
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
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
            }
        }
        .frame(height: height)
        .opacity(opacity)
        .animate {
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
                    Text(date, formatter: yearFormatter)
                        .font(.system(size: 18))
                    Text(date, formatter: dateFormatter)
                        .font(.system(size: 18))
                } else {
                    Text(date, formatter: dayFormatter)
                        .font(.system(size: 32))
                }
                Text(date, formatter: weekdayFormatter)
                    .font(.system(size: isYearDisplayed ? 18 : 20))
            }
            Spacer()
        }
        .foregroundColor(Color.white)
        .padding(.horizontal, 28)
        .frame(width: 100)
        .background {
            FluidGradient(
                blobs: [.blue, .green, .yellow, .orange, .red, .pink, .teal],
                highlights:  [.blue, .green, .yellow, .orange, .red, .pink, .purple, .teal, .indigo],
                speed: 0.5
            )
            .opacity(0.9)
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
                .frame(width: 14)
                .foregroundColor(.primary)
        })
    }

    /**
     画像が設定されていない場合：テキストコンテンツを表示
     画像が設定されている場合：画像を表示
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
                .allowsHitTesting(false) // clipはUI上のcropは起こるが内部では画像をそのままのサイズで保持しているため、予期せぬタップ判定をもたらす。それを回避するためのワークアラウンド。 https://stackoverflow.com/questions/63300411/clipped-not-actually-clips-the-image-in-swiftui
        } else {
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
