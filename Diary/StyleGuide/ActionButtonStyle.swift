//
//  ActionButtonStyle.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import SwiftUI

public struct ActionButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let isActive: Bool
    let isAdaptiveSize: Bool
    let size: Size

    public enum Size {
        case small
        case medium

        var fontSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            }
        }

        var buttonWidth: CGFloat {
            switch self {
            case .small: return 100
            case .medium: return 200
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 15
            case .medium: return 15
            }
        }
    }

    public init(
        backgroundColor: Color = .adaptiveBlack,
        foregroundColor: Color = .adaptiveWhite,
        isAdaptiveSize: Bool = true,
        isActive: Bool = true,
        size: Size = .medium
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isActive = isActive
        self.isAdaptiveSize = isAdaptiveSize
        self.size = size
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .foregroundColor(
                self.foregroundColor
                    .opacity(!configuration.isPressed ? 1 : 0.5)
            )
            .padding(.vertical, size.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(
                        self.backgroundColor
                            .opacity(self.isActive && !configuration.isPressed ? 1 : 0.5)
                    )
                    .frame(width: size.buttonWidth)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#if DEBUG

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        let view = NavigationStack {
            VStack {
                Section(header: Text("Active")) {
                    Button("ぼたん") {}
                    NavigationLink("りんく", destination: EmptyView())
                }
                .buttonStyle(ActionButtonStyle())

                Section(header: Text("Active with Color")) {
                    Button("ぼたん") {}
                    NavigationLink("りんく", destination: EmptyView())
                }
                .buttonStyle(ActionButtonStyle(backgroundColor: .orange))

                Section(header: Text("Active, smal")) {
                    Button("ぼたん") {}
                    NavigationLink("りんく", destination: EmptyView())
                }
                .buttonStyle(ActionButtonStyle(size: .small))

                Section(header: Text("In-active")) {
                    Button("ぼたん") {}
                    NavigationLink("りんく", destination: EmptyView())
                }
                .buttonStyle(ActionButtonStyle(isActive: false))
                .disabled(true)
            }
        }

        return Group {
            view
                .environment(\.colorScheme, .light)
            view
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif
