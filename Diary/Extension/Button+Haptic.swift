//
//  Button+Haptic.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/14.
//

import SwiftUI

extension Button {
    init(
        actionWithHapticFB: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            action: {
                let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
                actionWithHapticFB()
            },
            label: label
        )
    }
}
