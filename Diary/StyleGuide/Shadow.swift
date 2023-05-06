//
//  Shadow.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

extension View {
    public func adaptiveShadow(radius: CGFloat = 8, positionX: CGFloat = 0, positionY: CGFloat = 5) -> some View {
        self.modifier(
            AdaptiveShadow(radius: radius, positionX: positionX, positionY: positionY)
        )
    }
}

struct AdaptiveShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let radius: CGFloat
    let positionX: CGFloat
    let positionY: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(
                color: colorScheme == .light ? Color.gray.opacity(0.4) : Color.adaptiveWhite,
                radius: colorScheme == .light ? radius : 0,
                x: colorScheme == .light ? positionX : 0,
                y: colorScheme == .light ? positionY : 0
            )
    }
}

#if DEBUG

struct AdaptiveShadow_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 300, height: 300)
                .foregroundColor(.adaptiveWhite)
                .adaptiveShadow()
        }
    }

    static var previews: some View {
        Group {
            content
                .environment(\.colorScheme, .light)
            content
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif

