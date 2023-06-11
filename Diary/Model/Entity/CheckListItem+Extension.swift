//
//  CheckListItem+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/07.
//

import Foundation

extension CheckListItem: BaseModel {
    static func create(title: String) throws {
        let now = Date()
        let checkListItem = CheckListItem(context: CoreDataProvider.shared.container.viewContext)

        checkListItem.title = title
        checkListItem.createdAt = now
        checkListItem.updatedAt = now

        try checkListItem.save()
    }
}
