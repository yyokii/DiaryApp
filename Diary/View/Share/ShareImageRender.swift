//
//  ShareImageRender.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/26.
//

import SwiftUI

struct ShareImageRender: View {
    let backgroundColor: Color
    let item: Item
    let contentPattern: ShareContentPattern

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
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = .init(identifier: "en")
        return formatter
    }()

    var body: some View {
        layout
            .padding(.bottom)
            .background {
                shareCardBackground
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appBlack, lineWidth: 3)
            )
            .padding()
    }
}

private extension ShareImageRender {

    var layout: some View {
        VStack(spacing: 0) {
            year
                .padding(.top, 8)
                .padding(.trailing)

            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 20) {
                    date
                    headerDivider
                    title
                    Spacer()
                }
                .padding(.horizontal)

                if contentPattern == .imageAndText,
                   let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData) {
                    diaryImage(uiImage)
                }

                if contentPattern == .imageAndText || contentPattern == .text {
                    diaryBody
                        .padding(.horizontal)
                } else if contentPattern == .checkList {
                    checkList
                        .padding(.horizontal)
                }
            }
        }
    }

    var headerDivider: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 5, height: 30)
    }

    var shareCardBackground: some View {
        backgroundColor.opacity(0.8)
            .cornerRadius(24)
    }

    func diaryImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .padding(.vertical, 10)
    }

    var year: some View {
        HStack {
            Spacer()
            Text(item.date!, formatter: yearFormatter)
                .font(.system(size: 16))
        }
    }

    var date: some View {
        VStack(alignment: .center) {
            Text(item.date!, formatter: dateFormatter)
                .font(.system(size: 20))
            Text(item.date!, formatter: weekdayFormatter)
                .font(.system(size: 20))
                .textCase(.lowercase)
        }
    }

    var title: some View {
        Text(item.title ?? "")
            .font(.system(.title2, weight: .black))
    }

    var diaryBody: some View {
        Text(item.body ?? "")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 14))
            .fontWeight(.medium)
    }

    var checkList: some View {
        VStack(spacing: 12) {
            if let itemsCount = item.checkListItems?.count,
               itemsCount >= 2 {
                Text("合計\(itemsCount)個のチェックリストを達成しました")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            VStack(alignment: .center, spacing:8) {
                ForEach(item.checkListItemsArray) { checkListItem  in
                    HStack(spacing: 12) {
                        Image(systemName:"checkmark")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.green)

                        Text(checkListItem.title ?? "no title")
                            .font(.system(.body, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                }
            }
        }
    }
}

#if DEBUG

struct ShareImageRender_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            ScrollView {
                ShareImageRender(
                    backgroundColor: .white,
                    item: .makeRandom(withImage: true),
                    contentPattern: .imageAndText
                )
                .padding()

                ShareImageRender(
                    backgroundColor: .white,
                    item: .makeRandom(),
                    contentPattern: .text
                )
                .padding()

                ShareImageRender(
                    backgroundColor: .white,
                    item: .makeWithOnlyCheckList(),
                    contentPattern: .checkList
                )
                .padding()
            }
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
