//
//  DiaryDetailView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/05.
//

import SwiftUI

struct DiaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var textOptions: TextOptions
    @EnvironmentObject private var weatherData: WeatherData

    @ObservedObject var diaryDataStore: DiaryDataStore

    @State private var isEditing: Bool = false
    @State private var selectedContentType: DiaryContentType = .text
    @State private var isPresentedTextEditor: Bool = false
    @State private var isCheckListEditorPresented: Bool = false
    @State private var isImageViewerPresented: Bool = false
    @State private var isShareViewPresented: Bool = false
    @State private var showDeleteAlert: Bool = false

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
                            diaryAdditionalInfo
                                .padding(.top, 40)
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
            .navigationTitle(Locale.appLocaleFullDateFormatter.string(from: diaryDataStore.selectedDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationToolBar
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            deleteAlert
        }
        .sheet(isPresented: $isShareViewPresented, content: {
            if let item = diaryDataStore.originalItem {
                ShareView(item: item)
                    .presentationDetents([.large])
            }
        })
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
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isEditing = false
                    }
                    save()
                }, label: {
                    Text("保存")
                })
            } else {
                headerMenu
            }
        }
    }

    var headerMenu: some View {
        Menu {
            Button(actionWithHapticFB: {
                isShareViewPresented = true
            }, label: {
                HStack {
                    Text("共有する")
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            })

            Button(actionWithHapticFB: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isEditing = true
                }
            }, label: {
                HStack {
                    Text("編集する")
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            })

            Button(actionWithHapticFB: {
                showDeleteAlert = true
            }, label: {
                Text("削除する")
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            })
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .foregroundColor(.primary)
        }
    }

    var deleteAlert: Alert {
        Alert(title: Text("この日記を削除します"),
              message: Text("削除すると復元することはできません。"),
              primaryButton: .cancel(Text("キャンセル")),
              secondaryButton: .destructive(Text("削除する"), action: { delete() }))
    }

    @ViewBuilder
    var image: some View {
        DiaryImageView(
            selectedImage: $diaryDataStore.selectedImage,
            isEditing: isEditing
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                isImageViewerPresented = true
            }
        }
        .fullScreenCover(isPresented: $isImageViewerPresented) {
            if !isEditing,
               let image = diaryDataStore.selectedImage {
                ImageViewer(image: image)
                    .overlay(alignment: .topTrailing) {
                        XButton {
                            isImageViewerPresented = false
                        }
                        .padding()
                    }
            }
        }
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
        VStack(spacing: 60) {
            CheckList(diaryDataStore: diaryDataStore, isEditable: $isEditing)
            if isEditing {
                Button(actionWithHapticFB: {
                    isCheckListEditorPresented = true
                }) {
                    CheckListEditButton()
                }
                .sheet(isPresented: $isCheckListEditorPresented) {
                    CheckListEditor()
                        .padding(.top)
                }
            }
        }
    }

    var diaryAdditionalInfo: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                cratedAt
                updatedAt
            }
        }
    }

    @ViewBuilder
    var cratedAt: some View {
        if let createdAt = diaryDataStore.originalItem?.createdAt {
            HStack {
                Text("作成日: ")
                Text(Locale.appLocaleFullDateFormatter.string(from: createdAt))
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    var updatedAt: some View {
        if let updatedAt = diaryDataStore.originalItem?.updatedAt {
            HStack {
                Text("更新日: ")
                Text(Locale.appLocaleFullDateFormatter.string(from: updatedAt))
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
    }

    // MARK: Action

    func updateBookmarkState() {
        diaryDataStore.isBookmarked.toggle()
        do {
            try diaryDataStore.updateBookmarkState()
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
