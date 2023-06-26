//
//  Persistence.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/23.
//

import CoreData

public class CoreDataProvider: ObservableObject {
    static let shared = CoreDataProvider()

    @Published var coreDataProviderError: CoreDataProviderError?

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Diary")

        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let self,
               let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                self.coreDataProviderError = .failedToInit(error: error)
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension CoreDataProvider {
    static var preview: CoreDataProvider = {
        let result = CoreDataProvider()
        let viewContext = result.container.viewContext

        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.date = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}

public enum CoreDataProviderError: Error, LocalizedError {
    case failedToInit(error: Error?)

    public var errorDescription: String? {
        switch self {
        case .failedToInit:
            return "Failed to setup"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .failedToInit(let error):
            return "Sorry, please check message👇\n\(error?.localizedDescription ?? "")"
        }
    }
}
