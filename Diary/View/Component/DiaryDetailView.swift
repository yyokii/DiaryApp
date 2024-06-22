//
//  DiaryDetailView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/05.
//

import SwiftUI

/// 日記の詳細画面
///
/// DiaryListでForeachの中のNavigationLink内で使用しており、値が変わった時にForeach内の全てのDiaryDetailViewが再描画されている。
struct DiaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var weatherData: WeatherData
    @EnvironmentObject private var textOptions: TextOptions

    @ObservedObject var diaryDataStore: DiaryDataStore

    @State private var selectedContentType: DiaryContentType = .text

    @State private var isCheckListEditorPresented: Bool = false
    @State private var isImageViewerPresented: Bool = false
    @State private var isShareViewPresented: Bool = false
    @State private var isTextEditorPresented: Bool = false
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DiaryDateButton(selectedDate: $diaryDataStore.selectedDate)
                            .frame(maxWidth: .infinity)

                        image
                            .padding(.horizontal, isImageSet ? 0 : 20)

                        VStack(spacing: 20) {
                            header
                            ContentTypeSegmentedPicker(selectedContentType: $selectedContentType)
                            VStack(alignment: .leading, spacing: 8) {
                                diaryContent
                                // TODO: 表示箇所を変える
//                                diaryAdditionalInfo
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationToolBar
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            deleteAlert
        }
        .sheet(isPresented: $isShareViewPresented) {
            if let item = diaryDataStore.originalItem {
                ShareView(item: item)
                    .presentationDetents([.large])
            }
        }
        .sheet(isPresented: $isTextEditorPresented) {
            DiaryTextEditor(bodyText: $diaryDataStore.bodyText) {
                isTextEditorPresented = false
                save()
            }
        }
        .onDisappear {
            save()
        }
        .onChange(of: diaryDataStore.selectedImage) {
            save()
        }
        .onChange(of: diaryDataStore.selectedWeather) {
            save()
        }
        .onChange(of: diaryDataStore.selectedDate) {
            save()
        }
        .onChange(of: diaryDataStore.checkListItems) {
            save()
        }
        .onAppear {
            if diaryDataStore.bodyText.isEmpty {
                selectedContentType = .checkList
            }
        }
    }
}

private extension DiaryDetailView {
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
            headerMenu
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
        DiaryImageView(selectedImage: $diaryDataStore.selectedImage)
            .contentShape(Rectangle())
            .onTapGesture {
                isImageViewerPresented = true
            }
            .fullScreenCover(isPresented: $isImageViewerPresented) {
                if let image = diaryDataStore.selectedImage {
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
        WeatherSelectButton(selectedWeather: $diaryDataStore.selectedWeather)
            .asyncState(
                weatherData.phase,
                loadingContent: ProgressView()
                    .frame(width: WeatherIcon.size.width, height: WeatherIcon.size.height)
            )
    }

    @ViewBuilder
    var diaryContent: some View {
        switch selectedContentType {
        case .text:
            DiaryText(text: diaryDataStore.bodyText) {
                withAnimation {
                    isTextEditorPresented = true
                }
            }
        case .checkList:
            checkList
                .padding(.bottom, 100)
        }
    }

    @ViewBuilder
    var title: some View {
        InputTitle(title: $diaryDataStore.title)
    }

    var checkList: some View {
        VStack(spacing: 40) {
            CheckList(diaryDataStore: diaryDataStore)
            Button(actionWithHapticFB: {
                isCheckListEditorPresented = true
            }) {
                CheckListEditButton()
            }
            .sheet(isPresented: $isCheckListEditorPresented) {
                NavigationStack {
                    CheckListEditor()
                }
            }
        }
        .frame(maxWidth: .infinity)
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
        } catch {
            bannerState.show(with: error)
        }
    }

    func delete() {
        do {
            try diaryDataStore.delete()
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
