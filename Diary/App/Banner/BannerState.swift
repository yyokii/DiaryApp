//
//  BannerState.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import Combine

final class BannerState: ObservableObject {
    @Published var isPresented: Bool = false
    // TODO: change value
    private(set) var title: String = "this is title"
    private(set) var systemImage: String = "star.fill"

    func show(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
        isPresented = true
    }
}
