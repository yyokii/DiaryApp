//
//  DiaryItem.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

struct DiaryItem: View {
    @EnvironmentObject private var bannerState: BannerState

    @ObservedObject var item: Item

    let height: CGFloat = 140
    let cornerRadius: CGFloat = 10

    let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }()

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.adaptiveWhite)
                .adaptiveShadow()

            HStack(alignment: .top, spacing: 20) {
                diaryDate
                    .padding(.leading, 20)

                ZStack(alignment: .topTrailing) {
                    diaryContent
                    bookMarkButton
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                }
            }
        }
        .frame(height: height)
    }
}


private extension DiaryItem {
    var diaryDate: some View {
        VStack(alignment: .center) {
            Spacer()

            if let date = item.date {
                Text(date, formatter: dayFormatter)
                    .font(.system(size: 32))
                Text(date, formatter: weekdayFormatter)
                    .font(.system(size: 20))
            }
            Spacer()
        }
        .frame(width: 50)
    }

    var bookMarkButton: some View {
        Button {
            bookMark()
        } label: {
            Image(systemName: item.isFavorite ? "bookmark.fill" : "bookmark")
                .resizable()
                .scaledToFit()
                .frame(width: 14)
                .foregroundColor(.primary)
        }
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

        } else {
            VStack(alignment: .leading, spacing: 14) {
                Text(item.title ?? "")
                    .font(.system(size: 36))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.trailing, 40)

                Text(item.body ?? "")
                    .font(.system(size: 12))
                    .lineSpacing(4)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
        }
    }

    func bookMark() {
        item.isFavorite = !item.isFavorite
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
        }

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
