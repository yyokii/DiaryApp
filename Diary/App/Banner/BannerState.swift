//
//  BannerState.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import Combine
import Foundation

final class BannerState: ObservableObject {
    @Published var isPresented: Bool = false

    private(set) var message: String = BannerState.defaultMessage
    private static let defaultMessage = "Something went wrong, try again🙏"

    func show(message: String) {
        self.message = message
        isPresented = true
    }

    func show(with error: Error) {
        if let localizedError = error as? LocalizedError {
            show(message: localizedError.recoverySuggestion ?? BannerState.defaultMessage)
        } else {
            show(message: BannerState.defaultMessage)
        }
    }
}
