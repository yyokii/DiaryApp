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

    @ObservedObject var diaryDataStore: DiaryDataStore

    @State private var isEditing: Bool = false
    @FocusState private var focusedField: FocusedField?

    private let imageHeight: CGFloat = 300

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    image
                    VStack(spacing: 20) {
                        header
                        diaryBody
                        if isEditing {
                            saveButton
                            deleteButton
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, paddingTopToImage)
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
        }
        .onSubmit {
            if focusedField == .title {
                focusedField = .body
            } else {
                focusedField = nil
            }
        }
    }
}

private extension DiaryDetailView {

    var date: String {
        if let date = diaryDataStore.selectedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.locale = .current
            return formatter.string(from: date)
        } else {
            return "no date"
        }
    }

    var paddingTopToImage: CGFloat {
        // 画像標示関連Viewが標示されている場合とそれ以外で見栄えを変える
        isEditing || diaryDataStore.selectedImage != nil
        ? 0
        : 40
    }

    // MARK: View

    var navigationToolBar: some View {
        HStack {
            Button {
               update()
            } label: {
                Image(systemName: diaryDataStore.isBookmarked ? "bookmark.fill" : "bookmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14)
                    .foregroundColor(.primary)
            }

            if isEditing {
                Button {
                    diaryDataStore.updateValuesWithOriginalData()
                    isEditing = false
                } label: {
                    Text("キャンセル")
                }
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isEditing = true
                    }
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: 22)
                }
            }
        }
    }

    @ViewBuilder
    var image: some View {
        Group {
            if isEditing {
                AddPhoto(selectedImage: $diaryDataStore.selectedImage)
            } else if let uiImage = diaryDataStore.selectedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
    }

    @ViewBuilder
    var header: some View {
        if isEditing {
            VStack {
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
            WeatherPicker(selectedWeather: $diaryDataStore.selectedWeather)
        } else {
            Image(systemName: diaryDataStore.selectedWeather)
                .resizable()
                .scaledToFit()
                .frame(width:24)
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
            InputBody(bodyText: $diaryDataStore.bodyText)
        } else if !diaryDataStore.bodyText.isEmpty {
            Text(diaryDataStore.bodyText)
                .textOption(textOptions)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .frame(height: 250, alignment: .top)
        }
    }

    var saveButton: some View {
        Button("保存する🎉") {
            save()
        }
        .buttonStyle(ActionButtonStyle())
    }

    var deleteButton: some View {
        Button("削除する🗑️") {
            delete()
        }
        .buttonStyle(ActionButtonStyle(backgroundColor: .red))
    }

    // MARK: Action

    func update() {
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
    }

    static var previews: some View {
        Group {
            content(withImage: true)
                .environment(\.colorScheme, .light)
            content(withImage: true)
                .environment(\.colorScheme, .dark)
        }

        Group {
            content(withImage: false)
                .environment(\.colorScheme, .light)
            content(withImage: false)
                .environment(\.colorScheme, .dark)
        }
    }
}

#endif
