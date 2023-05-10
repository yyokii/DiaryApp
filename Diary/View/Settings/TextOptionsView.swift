//
//  TextOptionsView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/10.
//

import SwiftUI

struct TextOptionsView: View {
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var textOptions: TextOptions

    @State private var fontSize: CGFloat = TextOptions.defaultFontSize
    @State private var lineSpacing: CGFloat = TextOptions.defaultLineSpacing

    private let userDefault = UserDefaults.standard

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("日記本文のテキスト設定を変更できます😄")
                    .font(.system(size: 16))
                previousSettingsDemo
                downImage
                newSettingsDemo
                fontSizeSlider
                lineSpacingSlider
                saveButton
            }
            .padding(20)
        }
        .onAppear {
            fontSize = textOptions.fontSize
            lineSpacing = textOptions.lineSpacing
        }
        .navigationTitle("テキスト設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}


private extension TextOptionsView {

    // MARK: View

    var previousSettingsDemo: some View {
        Text("これは現在の設定の設定です。\n日記の本文はこのように表示されています。\n設定を変更するには下部のスライダーを変更してみてください🦈")
            .textOption(
                .init(
                    fontSize: textOptions.fontSize,
                    lineSpacing: textOptions.lineSpacing
                )
            )
            .frame(height: 100)
    }

    var newSettingsDemo: some View {
        Text("これはデモ用のテキストです。\n変更後の日記の本文はこのように表示されます。\n設定を保存するには下部のボタンを押してください🦄")
            .textOption(
                .init(
                    fontSize: fontSize,
                    lineSpacing: lineSpacing
                )
            )
            .frame(height: 200)
    }

    var downImage: some View {
        VStack {
            Image(systemName: "chevron.down")
                .font(.system(size: 30))
            Image(systemName: "chevron.down")
                .font(.system(size: 30))
        }
    }

    var fontSizeSlider: some View {

        VStack {
            Slider(
                value: $fontSize,
                in: TextOptions.fontSizeRange,
                step: 1
            ) {
                Text("font size")
            } minimumValueLabel: {
                Text("小")
            } maximumValueLabel: {
                Text("大")
            }
        }
    }

    var lineSpacingSlider: some View {
        Slider(
            value: $lineSpacing,
            in: TextOptions.lineSpacingRange,
            step: 1
        ) {
            Text("line spacing")
        } minimumValueLabel: {
            Text("狭")
        } maximumValueLabel: {
            Text("広")
        }
    }

    var saveButton: some View {
        Button("保存") {
            textOptions.save(fontSize: fontSize, lineSpacing: lineSpacing)
        }
        .buttonStyle(ActionButtonStyle())
    }

    // MARK: Action
}

#if DEBUG

struct TextOptionsView_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            TextOptionsView()
                .environmentObject(
                    TextOptions(
                        fontSize: TextOptions.fontSizeRange.lowerBound,
                        lineSpacing: TextOptions.lineSpacingRange.lowerBound
                    )
                )
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

