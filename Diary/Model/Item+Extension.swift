//
//  Item+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/24.
//

import CoreData
import SwiftUI

extension Item {
    /*
     NSManagedObjectはObservableObjectを継承しているが、Publishedなどでプロパティの変更通知はしていないので、bjectWillChange.send()を呼ぶようにあoverrideしている
     https://developer.apple.com/forums/thread/121897
     */
    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}

extension Item: BaseModel {
#if DEBUG
    static func makeRandom(withImage: Bool = false) -> Item {
        let bodySourceString = "AaGgYyQq123あいうえお漢字カタカナ@+"
        var body = ""
        let repeatCount = Int.random(in: 1...10)
        for _ in 1...repeatCount {
            body += bodySourceString
        }

        let newItem = Item(context: CoreDataProvider.shared.container.viewContext)
        newItem.body = body
        newItem.createdAt = Date()
        newItem.emoji = ["🏝️", "📝", "🎨", "🎉", "💎"].randomElement()
        newItem.isFavorite = Bool.random()
        newItem.updatedAt = Date()
        newItem.weather = "sunny"

        if withImage {
            let image: Data = UIImage(named: "sample")!.jpegData(compressionQuality: 0.5)!
            newItem.imageData = image
        } else {
            newItem.imageData = nil
        }
        return newItem
    }
#endif

    static var thisMonth: NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let now = Date()
        request.predicate = NSPredicate(
            format: "createdAt >= %@ && createdAt < %@",
            now.startOfMonth! as CVarArg,
            now.endOfMonth! as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }

    static var favorites: NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(
            format: "isFavorite == true"
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }

    static func itemsOfMonth(date: Date) throws -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = itemsOfMonth(date: date)
        do {
            let result = try  CoreDataProvider.shared.container.viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("🚨 \(error.localizedDescription)")
            throw BaseModelError.databaseOperationError(error: error)
        }
    }

    static func itemsOfMonth(date: Date) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt >= %@ && createdAt < %@",
            date.startOfMonth! as CVarArg,
            date.endOfMonth! as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }

    /**
     今日までの継続日数を算出する
     今日未作成の場合は昨日までの継続日数を出力
     */
    // TODO: 引数変更してテストする
    static func calculateConsecutiveDays(_ context: NSManagedObjectContext) throws -> Int {
        var items = try context.fetch(all)
        guard !items.isEmpty,
              let latestItemCreatedAt = items[0].createdAt
        else { return 0 }

        var count = 0
        let now = Date()

        // 最新のItemと今日の日付が同じかどうかを判別する
        let dayDiffBetweenLatestItemAndNow = Calendar.current.dateComponents([.day], from: latestItemCreatedAt, to: now).day

        let hasTodayItem = dayDiffBetweenLatestItemAndNow == 0
        if hasTodayItem {
            items.removeFirst()
        }

        for item in items {
            let currentItemDate = Calendar.current.startOfDay(for: item.createdAt!)
            let expectedDate = Calendar.current.date(byAdding: .day, value: -(count + 1), to: now)!
            let expectedDateStartOfDay = Calendar.current.startOfDay(for: expectedDate)

            if currentItemDate == expectedDateStartOfDay {
                count += 1
            } else {
                break
            }
        }

        return hasTodayItem ? count + 1 : count
    }
}
