//
//  BaseModel.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/24.
//

import CloudKit
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
            if let ckError = error as? CKError {
                if ckError.code == CKError.Code.serverRejectedRequest {
                    throw BaseModelError.needToCheckSpace(error: error)
                }
                throw BaseModelError.databaseOperationError(error: error)
            } else {
                throw BaseModelError.databaseOperationError(error: error)
            }
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
    case needToCheckSpace(error: Error?)

    public var errorDescription: String? {
        switch self {
        case .databaseOperationError:
            return "動作が正常に完了しませんでした"
        case .needToCheckSpace:
            return "動作が正常に完了しませんでした"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .databaseOperationError(let error):
            return "\(error?.localizedDescription ?? "")"
        case .needToCheckSpace:
            return "iCloud連携ができませんでした。設定やiCloudの容量をご確認ください。"
        }
    }
}
