//
//  OffsetViewModifier.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/06/01.
//

import SwiftUI

struct OffsetModifier: ViewModifier {
    @Binding var offset: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy -> Color in // https://blog.personal-factory.com/2021/06/29/void-method-in-geometryreader/
                    let minY = proxy.frame(in: .named("SCROLL")).minY

                    DispatchQueue.main.async {
                        self.offset = minY
                    }

                    return Color.clear
                }
                , alignment: .top
            )
    }
}
