//
//  ShareCardBackgroundColorList.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/07/25.
//

import SwiftUI

struct ShareCardBackgroundColorList: View {

    @Binding var selectedColor: Color

    private let columns: [GridItem] = Array(
        repeating: .init(
            .fixed(40),
            spacing: 30,
            alignment: .top
        ),
        count: 3
    )

    private let backgroundColors: [Color] = [
        .white, .hex(0xdcd2e4), .hex(0xe4d2d2),
        .hex(0xd2dfe4), .hex(0xe1e4d2), .hex(0xd2e4d8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
            ForEach(backgroundColors, id: \.self) { color in
                Button(actionWithHapticFB: {
                    selectedColor = color
                }) {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.adaptiveBlack, lineWidth: 3)
                            )

                        if color == selectedColor {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16))
                                .bold()
                                .foregroundColor(.appBlack)
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG

struct ShareCardBackgroundColorList_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            ShareCardBackgroundColorList(selectedColor: .constant(.white))
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
