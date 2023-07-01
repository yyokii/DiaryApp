//
//  ContentTypeSegmentedPicker.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/16.
//

import SwiftUI

struct ContentTypeSegmentedPicker: View {
    @Binding var selectedContentType: DiaryContentType

    var body: some View {
        Picker("", selection: $selectedContentType) {
            ForEach(DiaryContentType.allCases, id: \.self) { option in
                Text(option.name)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
