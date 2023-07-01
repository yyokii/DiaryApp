//
//  DiaryDetailView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/05.
//

import SwiftUI

struct DiaryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var textOptions: TextOptions
    @EnvironmentObject private var weatherData: WeatherData

    @ObservedObject var diaryDataStore: DiaryDataStore

    @State private var isEditing: Bool = false
    @State private var selectedContentType: DiaryContentType = .text
    @State private var isPresentedTextEditor: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        image
                        VStack(spacing: 20) {
                            header
                            ContentTypeSegmentedPicker(selectedContentType: $selectedContentType)
                            diaryContent
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, paddingTopToImage)
                    }
                    .padding(.bottom, 500) // コンテンツの下部を見やすくするために余白を持たせる
                }
                .scrollIndicators(.hidden)

                if isPresentedTextEditor {
                    DiaryTextEditor(
                        bodyText: $diaryDataStore.bodyText,
                        isPresented: $isPresentedTextEditor
                    )
                }
            }
            .navigationTitle(date)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationToolBar
            }
        }
        .onAppear {
            diaryDataStore.updateValuesWithOriginalData()
            if diaryDataStore.bodyText.isEmpty {
                selectedContentType = .checkList
            }
        }
    }
}

private extension DiaryDetailView {

    var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = .current
        return formatter.string(from: diaryDataStore.selectedDate)
    }

    var paddingTopToImage: CGFloat {
        // 画像標示関連Viewが標示されている場合とそれ以外で見栄えを変える
        isEditing || diaryDataStore.selectedImage != nil
        ? 0
        : 40
    }

    // MARK: View

    var navigationToolBar: some View {
        HStack(spacing: 12) {
            Button(actionWithHapticFB: {
                updateBookmarkState()
            }, label: {
                Image(systemName: diaryDataStore.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            })

            if isEditing {
                Button(actionWithHapticFB: {
                    delete()
                }, label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                })

                Button(actionWithHapticFB: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isEditing = false
                    }
                    save()
                }, label: {
                    Text("保存")
                })
            } else {
                Button(actionWithHapticFB: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isEditing = true
                    }
                }, label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })
            }
        }
    }

    @ViewBuilder
    var image: some View {
        DiaryImageView(
            selectedImage: $diaryDataStore.selectedImage,
            isEditing: isEditing
        )
    }

    @ViewBuilder
    var header: some View {
        if isEditing {
            VStack(spacing: 20) {
                weather
                title
            }
        } else {
            HStack {
                title
                weather
            }
        }
    }

    @ViewBuilder
    var weather: some View {
        if isEditing {
            WeatherSelectButton(selectedWeather: $diaryDataStore.selectedWeather)
                .asyncState(weatherData.phase)
        } else {
            Image(systemName: diaryDataStore.selectedWeather.symbol)
                .resizable()
                .scaledToFit()
                .frame(width:24)
        }
    }

    @ViewBuilder
    var diaryContent: some View {
        switch selectedContentType {
        case .text:
            diaryBody
        case .checkList:
            CheckList(diaryDataStore: diaryDataStore, isEditable: $isEditing)
        }
    }

    @ViewBuilder
    var title: some View {
        if isEditing {
            InputTitle(title: $diaryDataStore.title)
        } else if !diaryDataStore.title.isEmpty {
            Text(diaryDataStore.title)
                .bold()
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    var diaryBody: some View {
        if isEditing {
            InputBodyButton(
                bodyText: diaryDataStore.bodyText) {
                    isPresentedTextEditor = true
                }
        } else if !diaryDataStore.bodyText.isEmpty {
            Text(diaryDataStore.bodyText)
                .textOption(textOptions)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }

    // MARK: Action

    func updateBookmarkState() {
        diaryDataStore.isBookmarked.toggle()
        do {
            try diaryDataStore.update()
        } catch {
            bannerState.show(with: error)
        }
    }

    func save() {
        do {
            try diaryDataStore.update()
            isEditing = false
        } catch {
            bannerState.show(with: error)
        }
    }

    func delete() {
        do {
            try diaryDataStore.delete()
            isEditing = false
            dismiss()
        } catch {
            bannerState.show(with: error)
        }
    }
}

#if DEBUG

struct DiaryDetailView_Previews: PreviewProvider {

    static func content(withImage: Bool) -> some View {
        DiaryDetailView(diaryDataStore: .init(item: .makeRandom(withImage: withImage)))
            .environmentObject(TextOptions.preview)
            .environmentObject(WeatherData())
    }

    static var previews: some View {
        Group {
            content(withImage: true)
                .environment(\.colorScheme, .light)
                .previewDisplayName("light, 画像あり")
            content(withImage: true)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("dark, 画像あり")
        }

        Group {
            content(withImage: false)
                .environment(\.colorScheme, .light)
                .previewDisplayName("light, 画像なし")
            content(withImage: false)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("dark, 画像なし")
        }
    }
}

#endif
