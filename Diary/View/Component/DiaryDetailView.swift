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
    @State private var isCheckListEditorPresented: Bool = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = .appLanguageLocale
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        image
                            .padding(.horizontal, isImageSet ? 0 : 20)
                            .padding(.top, isImageSet ? 0 : 20)

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
                        diaryDataStore: diaryDataStore,
                        isPresented: $isPresentedTextEditor
                    )
                }
            }
            .navigationTitle(dateFormatter.string(from: diaryDataStore.selectedDate))
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

    var paddingTopToImage: CGFloat {
        /**
         画像表示関連Viewで画像が設定されている場合とそれ以外で見栄えを変える
         画像が設定されている: 余白なし
         画像が設定されていない: 余白あり
         */
        isImageSet
        ? 0
        : 28
    }

    var isImageSet: Bool {
        diaryDataStore.selectedImage != nil
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
        HStack {
            title
            weather
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
            checkList
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

    var checkList: some View {
        VStack(spacing: 24) {
            CheckList(diaryDataStore: diaryDataStore, isEditable: $isEditing)
            if isEditing {
                Button(actionWithHapticFB: {
                    isCheckListEditorPresented = true
                }) {
                    editCheckListButton
                }
                .sheet(isPresented: $isCheckListEditorPresented) {
                    CheckListEditor()
                        .padding(.top)
                }
            }
        }
    }

    var editCheckListButton: some View {
        HStack {
            Image(systemName: "pencil")
                .font(.system(size: 16))
                .foregroundColor(.adaptiveBlack)
            Text("チェックリストを編集する")
                .font(.system(size: 14))
                .foregroundColor(.adaptiveBlack)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.appSecondary)
                .adaptiveShadow(size: .small)
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
