//
//  FloatingActionButton.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

struct FloatingButton: View {
    let action: () -> Void

    var body: some View {
        Button(actionWithHapticFB: action) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "plus")
                    .bold()
                    .font(.system(size: 20))
                    .foregroundColor(.adaptiveWhite)
                Text("作成")
                    .font(.system(size: 16))
                    .bold()
                    .foregroundStyle(Color.adaptiveWhite)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                Capsule()
                    .fill(Color.adaptiveBlack)
            }
        }
        .adaptiveShadow()
    }
}

#if DEBUG

struct FloatingButton_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            FloatingButton {
                print("tap button")
            }
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
