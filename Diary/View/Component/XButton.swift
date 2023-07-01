//
//  XButton.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/01.
//

import SwiftUI

struct XButton: View {

    let action: () -> Void

    var body: some View {
        Button(actionWithHapticFB: {
            action()
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.palette)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundStyle(
                    Color.adaptiveWhite,
                    Color.adaptiveBlack
                )
        })
    }
}
