//
//  BaseModel.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/24.
//

import Foundation
import CoreData

protocol BaseModel {
    func delete() throws
    func save() throws
}

extension BaseModel where Self: NSManagedObject {

    func delete() throws {
        CoreDataProvider.shared.container.viewContext.delete(self)
        do {
            try save()
        } catch {
            throw BaseModelError.databaseOperationError(error: error)
        }
    }

    func save() throws {
        do {
            try CoreDataProvider.shared.container.viewContext.save()
        } catch {
            throw BaseModelError.databaseOperationError(error: error)
        }
    }

    static var all: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: String(describing: self))
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }

    static func count() throws -> Int {
        let request = NSFetchRequest<Self>(entityName: String(describing: self))
        request.sortDescriptors = []
        do {
            let count = try CoreDataProvider.shared.container.viewContext.count(for: request)
            return count
        } catch {
            throw BaseModelError.databaseOperationError(error: error)
        }
    }
}

public enum BaseModelError: Error, LocalizedError {
    case databaseOperationError(error: Error?)

    public var errorDescription: String? {
        switch self {
        case .databaseOperationError:
            return "Failed to fetch data"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .databaseOperationError(let error):
            return "Sorry, please check message👇\n\(error?.localizedDescription ?? "")"
        }
    }
}
