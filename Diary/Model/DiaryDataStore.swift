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
     selectedDateはPickerの選択結果を伝達するために利用
     */
    @Published var title = ""
    @Published var bodyText = ""
    @Published var selectedDate: Date = Date()

    var isBookmarked = false
    var selectedWeather: WeatherSymbol = .sun
    var selectedPickerItem: PhotosPickerItem?
    var selectedImage: UIImage?

    private let originalItem: Item?
    private var originalItemImage: UIImage?

    init(item: Item? = nil) {
        originalItem = item
        updateValuesWithOriginalData()
    }

    // MARK: Validation

    var canCreate: Bool {
        validTitle && validBody
    }

    var validTitle: Bool {
        title.count >= InputTitle.titleCount.min &&
        title.count <= InputTitle.titleCount.max
    }

    var validBody: Bool {
        bodyText.count >= InputBody.bodyCount.min &&
        bodyText.count <= InputBody.bodyCount.max
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
            imageData: imageData
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

        // 値の変更があるかどうかを元の値との比較より行い、変更されている場合のみプロパティの更新を行う

        if originalItem.date != selectedDate {
            originalItem.date = selectedDate
        }

        if originalItem.title != title,
           !title.isEmpty {
            originalItem.title = title
        }

        if originalItem.body != bodyText,
           !bodyText.isEmpty {
            originalItem.body = bodyText
        }

        if originalItem.isBookmarked != isBookmarked {
            originalItem.isBookmarked = isBookmarked
        }

        if originalItem.weather != selectedWeather.symbol {
            originalItem.weather = selectedWeather.symbol
        }

        if originalItemImage != selectedImage {
            originalItem.imageData = selectedImage?.jpegData(compressionQuality: 0.5)
        }

        originalItem.updatedAt = Date()
        try originalItem.save()
    }
}

public enum DiaryDataStoreError: Error, LocalizedError {
    case notFoundItem // 操作対象のItemが存在しない
    case notValidData // 入力データが不適


    public var errorDescription: String? {
        switch self {
        case .notFoundItem:
            return "Not found item"
        case .notValidData:
            return "Not valid data"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notFoundItem:
            return "Sorry, restart your app and try again🙏"
        case .notValidData:
            return "Check your input datas"
        }
    }
}
