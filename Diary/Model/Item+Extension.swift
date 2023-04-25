//
//  Item+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/24.
//

import CoreData
import SwiftUI

extension Item: Model {
    #if DEBUG
    static func makeRandom(context: NSManagedObjectContext) -> Item {
        let newItem = Item(context: context)
        newItem.body = "this is demo data"
        newItem.createdAt = Date()
        newItem.emoji = ["🏝️", "📝", "🎨", "🎉", "💎"].randomElement()
        newItem.isFavorite = Bool.random()
        newItem.updatedAt = Date()
        newItem.weather = "sunny"
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
}
