//
//  DiaryTests.swift
//  DiaryTests
//
//  Created by Higashihara Yoki on 2023/04/25.
//

import XCTest
import CoreData

@testable import Diary

final class DiaryItemTests: XCTestCase {

    var coreDataProvider: MockCoreData?

    override func setUp() {
        coreDataProvider = .init()
    }

    override func tearDown() {
        coreDataProvider = nil
    }

    func testCalculateConsecutiveDays_今日は未作成で昨日は作成している場合() {
        // Given
        guard let coreDataProvider else { return }
        let yesterdayItem = Item.makeRandom(context: coreDataProvider.viewContext)
        yesterdayItem.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        try! coreDataProvider.viewContext.save()

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 1)
    }

    func testCalculateConsecutiveDays_昨日は未作成で今日は作成している場合() {
        // Given
        guard let coreDataProvider else { return }
        _ = Item.makeRandom(context: coreDataProvider.viewContext)
        try! coreDataProvider.viewContext.save()

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 1)
    }

    func testCalculateConsecutiveDays_昨日と今日作成している場合() {
        // Given
        guard let coreDataProvider else { return }
        _ = Item.makeRandom(context: coreDataProvider.viewContext)
        let yesterdayItem = Item.makeRandom(context: coreDataProvider.viewContext)
        yesterdayItem.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        try! coreDataProvider.viewContext.save()

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 2)
    }

    func testCalculateConsecutiveDays_今日を含め過去10日間作成している場合() {
        // Given
        guard let coreDataProvider else { return }
        let now = Date()
        for i in 0..<10 {
            let item = Item.makeRandom(context: coreDataProvider.viewContext)
            item.createdAt = Calendar.current.date(byAdding: .day, value: Int(-i), to: now)!
            try! coreDataProvider.viewContext.save()
        }

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 10)
    }

    func testCalculateConsecutiveDays_今日を含まず過去10日間作成している場合() {
        // Given
        guard let coreDataProvider else { return }
        let now = Date()
        for i in 1..<11 {
            let item = Item.makeRandom(context: coreDataProvider.viewContext)
            item.createdAt = Calendar.current.date(byAdding: .day, value: Int(-i), to: now)!
            try! coreDataProvider.viewContext.save()
        }

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 10)
    }

    func testCalculateConsecutiveDays_今日と昨日作成していない場合() {
        // Given
        guard let coreDataProvider else { return }
        let now = Date()
        for i in 2..<10 {
            let item = Item.makeRandom(context: coreDataProvider.viewContext)
            item.createdAt = Calendar.current.date(byAdding: .day, value: Int(-i), to: now)!
            try! coreDataProvider.viewContext.save()
        }

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 0)
    }

    func testCalculateConsecutiveDays_今日作成し昨日は2件作成し一昨日は1件作成している場合() {
        // Given
        guard let coreDataProvider else { return }
        let now = Date()
        for i in 0..<3 {
            createItem(diffFromToday: i)
            if i == 1 {
                createItem(diffFromToday: i)
            }
        }
        func createItem(diffFromToday: Int) {
            let item = Item.makeRandom(context: coreDataProvider.viewContext)
            item.createdAt = Calendar.current.date(byAdding: .day, value: Int(-diffFromToday), to: now)!
            try! coreDataProvider.viewContext.save()
        }

        // When
        let consecutiveDays = try! Item.calculateConsecutiveDays(coreDataProvider.viewContext)

        // Then
        XCTAssertEqual(consecutiveDays, 3)
    }
}
