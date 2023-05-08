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
 ・また、入力情報を保持するものはItem作成機能でも利用でき、Viewの状態を分割でき見通しが良くなる。
 以上の理由から本Modelを作成した。
 */
@MainActor
public class DiaryDataStore: ObservableObject {

    @Published var selectedDate: Date? = Date()
    @Published var title = ""
    @Published var bodyText = ""
    @Published var isFavorite = false
    @Published var selectedWeather = ""
    @Published var selectedPickerItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?

    private let originalItem: Item?
    private var originalItemImage: UIImage?

    init(item: Item? = nil) {
        originalItem = item
        updateValuesWithOriginalData()
    }

    @discardableResult
    func updateValuesWithOriginalData() -> Bool {
        guard let item = originalItem else {
            originalItemImage = nil
            return false
        }

        // Update published values
        if let date = item.date {
            self.selectedDate = date
        } else {
            self.selectedDate = nil
        }

        if let title = item.title {
            self.title = title
        }

        if let body = item.body {
            self.bodyText = body
        }

        self.isFavorite = item.isFavorite

        if let weather = item.weather {
            self.selectedWeather = weather
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

    func create() {
    }

    func delete() {
        guard let originalItem else {
            // TODO: エラー
            return
        }

        do {
            try originalItem.delete()
        } catch {
            // TODO: エラー
        }
    }

    func update() {
        guard let originalItem else {
            // TODO: エラー
            return
        }

        // 値の変更があるかどうかを元の値との比較より行い、変更されている場合のみプロパティの更新を行う

        if originalItem.date != selectedDate,
           selectedDate != nil {
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

        if originalItem.isFavorite != isFavorite {
            originalItem.isFavorite = isFavorite
        }

        if originalItem.weather != selectedWeather {
            originalItem.weather = selectedWeather
        }

        if originalItemImage != selectedImage {
            // TODO: 動作確認、変更時のみここにくるか
            originalItem.imageData = selectedImage?.jpegData(compressionQuality: 0.5)
        }

        originalItem.updatedAt = Date()

        do {
            try originalItem.save()
        } catch {
            // TODO: エラー処理
        }
    }
}
