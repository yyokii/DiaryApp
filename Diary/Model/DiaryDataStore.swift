//
//  DiaryDataStore.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/01.
//

import Combine
import CoreData
import Foundation
import _PhotosUI_SwiftUI
import UIKit

/**
 Diary item関連の状態、ロジックを保持するclass
 Itemの作成や編集などの画面で利用できる

 Itemエンティティにロジックを集約させても良かったが、すでに作成済みであるコンテンツの編集画面を考える際、
 元のデータと、それによって初期化された変数をViewで保持する必要があった。その際にinitでStateを初期化すると、initに渡している値が
 変わってもViewが再描画されることはない（initは初期化時のみ動作する）ので、Bindingとして持つ必要がある。
 ・そうなった場合、Itemのプロパティ分だけViewの変数が増える
 ・また、入力情報を保持するものはItem作成機能でも利用でき、Viewの状態を分割でき見通しが良くなる
 以上の理由から本Modelを作成した。
 */
@MainActor
public class DiaryDataStore: ObservableObject {

    /*
     Publishedの利用について
     title, bodyTextはValidation結果を伝達するために利用
     selectedDate, selectedImageはpickerの選択結果を伝達するために利用
     */
    @Published var title = ""
    @Published var bodyText = ""
    @Published var selectedDate: Date = Date()
    @Published var selectedImage: UIImage?
    @Published var checkListItems: [CheckListItem] = []

    var isBookmarked = false
    var selectedWeather: WeatherSymbol = .sun
    var selectedPickerItem: PhotosPickerItem?

    var originalItem: Item?
    private var originalItemImage: UIImage?

    /*
     新規作成の場合はまだItemを生成していないのでnil。
     編集などの場合は対象のItemを渡すことで更新可能。
     */
    init(item: Item? = nil) {
        originalItem = item
        updateValuesWithOriginalData()
    }

    // MARK: Validation

    /*
     @Published 属性プロパティを扱っている場合は、その変更により再計算される
     */

    var canCreate: Bool {
        validTitle && validContent
    }

    var validTitle: Bool {
        title.count >= Item.titleRange.lowerBound &&
        title.count <= Item.titleRange.upperBound
    }

    /**
     何れかのチェックリストがチェック済み or テキストが設定済みであればtrue
     */
    var validContent: Bool {
        if checkListItems.isEmpty {
            return bodyText.count > Item.textRange.lowerBound
            && bodyText.count <= Item.textRange.upperBound
        } else {
            return bodyText.count <= Item.textRange.upperBound
        }
    }

    // MARK: func

    @discardableResult
    func updateValuesWithOriginalData() -> Bool {
        guard let item = originalItem else {
            originalItemImage = nil
            return false
        }

        // Update values

        if let date = item.date {
            self.selectedDate = date
        } else {
            self.selectedDate = Date()
        }

        if let title = item.title {
            self.title = title
        }

        if let body = item.body {
            self.bodyText = body
        }

        self.isBookmarked = item.isBookmarked

        if let weather = item.weather {
            self.selectedWeather = WeatherSymbol.make(from: weather)
        }

        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            self.originalItemImage = uiImage
            self.selectedImage = uiImage
        } else {
            originalItemImage = nil
        }

        if !item.checkListItemsArray.isEmpty {
            self.checkListItems = item.checkListItemsArray
        }

        return  true
    }

    func create() throws {
        guard canCreate else {
            throw DiaryDataStoreError.notValidData
        }

        var imageData: Data?
        if let selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.5)
        }

        try Item.create(
            date: Calendar.current.startOfDay(for: selectedDate),
            title: title,
            body: bodyText,
            weather: selectedWeather.symbol,
            imageData: imageData,
            checkListItems: checkListItems
        )
    }

    func delete() throws {
        guard let originalItem else {
            throw DiaryDataStoreError.notFoundItem
        }

        try originalItem.delete()
    }

    func update() throws {
        guard let originalItem else {
            throw DiaryDataStoreError.notFoundItem
        }

        let updatedItem = originalItem

        // 値の変更があるかどうかを元の値との比較より行い、変更されている場合のみプロパティの更新を行う

        if originalItem.date != selectedDate {
            updatedItem.date = selectedDate
        }

        if originalItem.title != title,
           !title.isEmpty {
            updatedItem.title = title
        }

        if originalItem.body != bodyText {
            updatedItem.body = bodyText
        }

        if originalItem.weather != selectedWeather.symbol {
            updatedItem.weather = selectedWeather.symbol
        }

        if originalItemImage != selectedImage {
            updatedItem.imageData = selectedImage?.jpegData(compressionQuality: 0.5)
        }


// TODO:       ここで毎回更新してるのどうなのよ、これ起因でfetchrequestのitemsが呼ばれてそう
//        originalItem.checkListItems = NSSet(array: checkListItems)

        if updatedItem != originalItem {
            try saveItem(updatedItem)
        }
    }

    /**
     Update bookmark state(on/off)

     This is used for already created item.
     */
    func updateBookmarkState() throws {
        guard let originalItem else {
            throw DiaryDataStoreError.notFoundItem
        }

        if originalItem.isBookmarked != isBookmarked {
            let updatedItem = originalItem
            updatedItem.isBookmarked = isBookmarked
            try saveItem(updatedItem)
        }
    }

    func updateCheckListItemState(of item: CheckListItem) {
        if let foundItem = checkListItems.first(where: { $0.objectID == item.objectID
        }) {
            checkListItems.removeAll(where: {
                $0.objectID == foundItem.objectID
            })
        } else {
            checkListItems.append(item)
        }
    }

    private func saveItem(_ item: Item) throws {
        guard let originalItem else {
            throw DiaryDataStoreError.notFoundItem
        }
        item.updatedAt = Date()
        self.originalItem = item
        try originalItem.save()
    }
}

public enum DiaryDataStoreError: Error, LocalizedError {
    case notFoundItem // 操作対象のItemが存在しない
    case notValidData // 入力データが不適


    public var errorDescription: String? {
        switch self {
        case .notFoundItem:
            return "対象の日記が存在しません"
        case .notValidData:
            return "入力内容が不正です"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notFoundItem:
            return "エラーが発生しました、再度お試しください"
        case .notValidData:
            return "入力内容をご確認の上、再度お試しください"
        }
    }
}
