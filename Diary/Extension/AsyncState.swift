//
//  AsyncState.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/26.
//

import SwiftUI

@propertyWrapper
public struct AsyncState<Value: Codable>: DynamicProperty {
    @State public var phase: AsyncStatePhase = .initial

    @State private var value: Value

    public var wrappedValue: Value {
        get { value }
        /*
         State very likely uses some form of reference-based storage under the hood,
         which in turn makes it possible for it to opt out of Swift’s standard value mutation
         semantics (using the nonmutating keyword)
         — since the State wrapper itself is not actually being mutated
         when we assign a new property value.
         https://www.swiftbysundell.com/articles/mutating-and-nonmutating-swift-contexts/
         */
        nonmutating set {
            value = newValue
        }
    }

    public var isEmpty: Bool {
        if (value as AnyObject) is NSNull {
            return true
        } else if let val = value as? [Any], val.isEmpty {
            return true
        } else {
            return false
        }
    }

    public init(wrappedValue value: Value) {
        self._value = State(initialValue: value)
    }

    @State private var retryTask: (() async throws -> Value)?

    public func fetch(expiration: TimeInterval = 120, task: @escaping () async throws -> Value) async {
        self.retryTask = nil

        if !(phase.lastUpdated?.hasExpired(in: expiration) ?? true) {
            return
        }

        Task {
            do {
                phase = .loading
                value = try await task()
                if isEmpty {
                    self.retryTask = task
                    phase = .empty
                } else {
                    phase = .success(Date())
                }
            } catch _ as CancellationError {
                // Keep current state (loading)
            } catch {
                self.retryTask = task
                phase = .failure(error)
            }
        }
    }

    public func retry() async {
        guard let task = retryTask else { return }
        await fetch(task: task)
    }

    public func hasExpired(in interval: TimeInterval) -> Bool {
        phase.lastUpdated?.hasExpired(in: interval) ?? true
    }

    public func invalidate() {
        if case .success = phase {
            phase = .success(.distantPast)
        }
    }
}

extension Date {
    func hasExpired(in interval: TimeInterval) -> Bool {
        timeIntervalSince(self) >= interval
    }
}
