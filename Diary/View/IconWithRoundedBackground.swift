//
//  IconWithRoundedBackground.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/21.
//

import SwiftUI

struct IconWithRoundedBackground: View {

    let systemName: String
    let backgroundColor: Color

    var body: some View {
        Image(systemName: systemName)
            .frame(width: 30, height: 30)
            .bold()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(backgroundColor)
            }
    }
}
