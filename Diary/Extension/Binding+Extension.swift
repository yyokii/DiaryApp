//
//  Binding+Extension.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/07.
//

import SwiftUI

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
