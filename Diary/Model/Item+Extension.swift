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
    static func makeRandom(
        context: NSManagedObjectContext = CoreDataProvider.shared.container.viewContext,
        date: Date = Date(),
        withImage: Bool = false
    ) -> Item {
        let titleSourceString = "あ漢1"
        var title = ""
        let repeatCountForTitle = Int.random(in: 1...3)
        for _ in 1...repeatCountForTitle {
            title += titleSourceString
        }

        let bodySourceString = "AaGgYyQq123あいうえお漢字カタカナ@+"
        var body = ""
        let repeatCountForBody = Int.random(in: 1...10)
        for _ in 1...repeatCountForBody {
            body += bodySourceString
        }

        let newItem = Item(context: context)
        newItem.title = title
        newItem.body = body
        newItem.date = date
        newItem.createdAt = Date()
        newItem.isBookmarked = Bool.random()
        newItem.updatedAt = Date()
        newItem.weather = "sun.max"

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
            format: "date >= %@ && date < %@",
            now.startOfMonth! as CVarArg,
            now.endOfMonth! as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }

    static var bookmarks: NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(
            format: "isBookmarked == true"
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }

    static func itemsOfMonth(date: Date) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ && date < %@",
            date.startOfMonth! as CVarArg,
            date.endOfMonth! as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }

    /**
     今日までの継続日数を算出する。
     作成日をもとに算出している。従って毎日"いつかの"日記を書いていれば継続日数は増加する。
     今日未作成の場合は昨日までの継続日数を出力
     */
    static func calculateConsecutiveDays(_ context: NSManagedObjectContext = CoreDataProvider.shared.container.viewContext) throws -> Int {
        let request = all
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        var items = try context.fetch(request)
        guard !items.isEmpty,
              let latestItemDate = items.first?.createdAt
        else { return 0 }

        var count = 0
        let now = Date()

        // 最新のItemと今日の日付が同じかどうかを判別する
        let dayDiffBetweenLatestItemAndNow = Calendar.current.dateComponents([.day], from: latestItemDate, to: now).day

        let hasTodayItem = dayDiffBetweenLatestItemAndNow == 0
        if hasTodayItem {
            items.removeFirst()
        }

        for item in items {
            let currentItemDateStartOfDay = Calendar.current.startOfDay(for: item.createdAt!)
            let expectedDate = Calendar.current.date(byAdding: .day, value: -(count + 1), to: now)!
            let expectedStartOfDay = Calendar.current.startOfDay(for: expectedDate)

            let dayDiffBetweenCurrentItemAndExpected = Calendar.current.dateComponents(
                [.day],
                from: currentItemDateStartOfDay,
                to: expectedStartOfDay
            ).day

            if dayDiffBetweenCurrentItemAndExpected == 0 {
                count += 1
            } else if dayDiffBetweenCurrentItemAndExpected == -1 {
                // 同日に複数件作成している場合もあるのでその場合は次のループへ（countの変化はないので、expectedDateは同じでitemが更新されて再度処理される）
                continue
            } else {
                break
            }
        }

        return hasTodayItem ? count + 1 : count
    }

    static func create(
        date: Date,
        title: String,
        body: String,
        isBookmarked: Bool = false,
        weather: String,
        imageData: Data?
    ) throws {
        let now = Date()
        let diaryItem = Item(context: CoreDataProvider.shared.container.viewContext)

        diaryItem.date = date
        diaryItem.title = title
        diaryItem.body = body
        diaryItem.createdAt = now
        diaryItem.updatedAt = now
        diaryItem.isBookmarked = isBookmarked
        diaryItem.weather = weather

        if let imageData {
            diaryItem.imageData = imageData
        }

        try diaryItem.save()
    }
}
