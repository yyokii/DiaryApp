//
//  CheckListItem+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/07.
//

import CoreData

extension CheckListItem: BaseModel {

    #if DEBUG
    static func makeRandom(
        context: NSManagedObjectContext = CoreDataProvider.shared.container.viewContext,
        date: Date = Date()
    ) -> CheckListItem {
        let titleSourceString = "あ漢1"
        var title = ""
        let repeatCountForTitle = Int.random(in: 1...3)
        for _ in 1...repeatCountForTitle {
            title += titleSourceString
        }

        let newItem = CheckListItem(context: context)
        newItem.title = title
        newItem.createdAt = date
        newItem.updatedAt = date

        return newItem
    }
    #endif

    static func create(title: String) throws {
        let now = Date()
        let checkListItem = CheckListItem(context: CoreDataProvider.shared.container.viewContext)

        checkListItem.title = title
        checkListItem.createdAt = now
        checkListItem.updatedAt = now

        try checkListItem.save()
    }
}
