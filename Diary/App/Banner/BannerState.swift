//
//  BannerState.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import Combine
import Foundation
import SwiftUI

final class BannerState: ObservableObject {
    @Published var isPresented: Bool = false

    private static let defaultMessage = "Something went wrong, try again🙏"
    
    var mode: BannerState.Mode = .success(message: "Hi Diary App")

    func show(of mode: BannerState.Mode) {
        self.mode = mode
        isPresented = true

        mode.playHapticFeedBack()
    }

    func show(with error: Error) {
        let message = (error as? LocalizedError)?.recoverySuggestion ?? BannerState.defaultMessage
        show(of: .error(message: message))
    }
}

extension BannerState {
    enum Mode {
        case warning(message: String)
        case error(message: String)
        case success(message: String)

        var imageName: String {
            switch self {
            case .warning:
                return "exclamationmark"
            case .error:
                return "xmark"
            case .success:
                return "checkmark"
            }
        }

        var mainColor: Color {
            switch self {
            case .warning:
                return .yellow
            case .error:
                return .red
            case .success:
                return .green
            }
        }

        var imageBackgroundCol: String {
            switch self {
            case .warning:
                return "exclamationmark"
            case .error:
                return "xmark"
            case .success:
                return "checkmark"
            }
        }

        var message: String {
            switch self {
            case .warning(let message):
                return message
            case .error(let message):
                return message
            case .success(let message):
                return message
            }
        }

        func playHapticFeedBack() {
            let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
            generator.prepare()

            var notificationType: UINotificationFeedbackGenerator.FeedbackType = .success
            switch self {
            case .warning:
                notificationType = .warning
            case .error:
                notificationType = .error
            case .success:
                notificationType = .success
            }

            generator.notificationOccurred(notificationType)
        }
    }
}
