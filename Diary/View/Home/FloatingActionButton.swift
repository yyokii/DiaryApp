//
//  FloatingActionButton.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

struct FloatingButton: View {
    let action: () -> Void
    let icon: String

    let size: CGFloat = 70

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(actionWithHapticFB: action) {
                    Image(systemName: icon)
                        .bold()
                        .font(.system(size: 24))
                        .foregroundColor(.adaptiveWhite)
                        .padding(20)
                }
                .background {
                    Circle()
                        .fill(Color.adaptiveBlack)
                }
                .frame(width: size, height: size)
                .cornerRadius(size/2)
                .adaptiveShadow()
            }
        }
    }
}

#if DEBUG

struct FloatingButton_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            FloatingButton(action: {
                print("tap button")
            }, icon: "plus")
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
