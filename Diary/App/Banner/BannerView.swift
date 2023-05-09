//
//  BannerView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/08.
//

import Combine
import SwiftUI

struct BannerView: View {
    @EnvironmentObject var bannerState: BannerState
    @State private var dismissTask: Task<Void, Never>?

    private let baseHeight: CGFloat = 52
    private let shadowY: CGFloat = 5

    var body: some View {
        VStack {
            banner

            // Banner部分を上部に配置するためにSpacerを付与
            Spacer()
        }
    }
}

private extension BannerView {

    var banner: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Label(bannerState.title, systemImage: bannerState.systemImage)
                    .padding(16)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .foregroundColor(Color.white)
                    )
                    .drawingGroup() // テキストの変更とオフセットの変更アニメーションを同期させるために使用。（memo: これにもしViewが.clearなどを利用していても、タッチイベントは発生する（透過しない）ようになる。）
                    .offset(y: bannerState.isPresented ? 0 : -(geometry.safeAreaInsets.top + baseHeight))
                    .animation(Animation.spring(), value: bannerState.isPresented)
            }
            .background(.clear) // Clear view does not receive touches. バナーの箇所だけタッチイベントを有効にする。
            .frame(maxWidth: .infinity)
            .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: shadowY)
            .frame(height: baseHeight)
            .onTapGesture {
                bannerState.isPresented = false
            }
        }
        .frame(height: baseHeight)
        .border(.indigo)
        .onReceive(bannerState.$isPresented) { isPresented in
            if isPresented {
                dismissTask = Task.init { @MainActor in
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    bannerState.isPresented = false
                }
            } else {
                dismissTask?.cancel()
            }
        }
    }
}
