//
//  BaseModel.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/24.
//

import Foundation
import CoreData


protocol Model {
    func delete() throws
    func save() throws
}

extension Model where Self: NSManagedObject {

    func delete() throws {
        CoreDataProvider.shared.container.viewContext.delete(self)
        try save()
    }

    func save() throws {
        try CoreDataProvider.shared.container.viewContext.save()
    }

    static var all: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: String(describing: self))
        request.sortDescriptors = []
        return request
    }
}
