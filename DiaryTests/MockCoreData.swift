//
//  MockCoreData.swift
//  DiaryTests
//
//  Created by Higashihara Yoki on 2023/04/26.
//

import Foundation
import CoreData

final public class MockCoreData {
    let container:NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Diary")

        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)"
                )
            }
        }
    }

    private(set) lazy var viewContext: NSManagedObjectContext = {
        container.viewContext
    }()
}
