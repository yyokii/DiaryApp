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
                        weather
                        title
                        diaryBody
                        if isEditing {
                            saveButton
                            deleteButton
                        }
                    }
                    .padding(.horizontal, 40)
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

    // MARK: View

    var navigationToolBar: some View {
        HStack {
            Button {
               update()
            } label: {
                Image(systemName: diaryDataStore.isFavorite ? "bookmark.fill" : "bookmark")
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
                    isEditing = true
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
        if isEditing {
            AddPhoto(selectedImage: $diaryDataStore.selectedImage)
        } else if let uiImage = diaryDataStore.selectedImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
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
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
                .frame(height: 250, alignment: .top)
        }
    }

    var saveButton: some View {
        Button("Save") {
            save()
        }
        .buttonStyle(ActionButtonStyle())
    }

    var deleteButton: some View {
        Button("Delete") {
            delete()
        }
        .buttonStyle(ActionButtonStyle(backgroundColor: .orange))
    }

    // MARK: Action

    func update() {
        diaryDataStore.isFavorite.toggle()
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

    static var content: some View {
        DiaryDetailView(diaryDataStore: .init(item: .makeRandom(withImage: true)))
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
