//
//  CreateDiaryView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import PhotosUI
import SwiftUI

struct CreateDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var weatherData: WeatherData
    @EnvironmentObject private var bannerState: BannerState
    @EnvironmentObject private var textOptions: TextOptions

    @StateObject private var diaryDataStore: DiaryDataStore = DiaryDataStore()

    @State private var isPresentedDatePicker: Bool = false
    @State private var selectedContentType: DiaryContentType = .text

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .appLanguageLocale
        return formatter
    }()
    private let dateRange: ClosedRange<Date> = Date(timeIntervalSince1970: 0)...Date()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    dismissButton
                        .padding(.top)
                    header
                        .padding(.top)
                    scrollContent
                }
            }
        }
        .tint(.adaptiveBlack)
        .onReceive(weatherData.$todayWeather , perform: { todayWeather in
            guard let todayWeather else { return }
            diaryDataStore.selectedWeather = .make(from: todayWeather.symbolName)
        })
    }
}

private extension CreateDiaryView {

    // MARK: View

    var dismissButton: some View {
        HStack {
            Spacer()
            XButton {
                dismiss()
            }
            .padding(.trailing)
        }
    }

    var header: some View {
        HStack {
            DiaryDateButton(selectedDate: $diaryDataStore.selectedDate)
                .padding(.leading)
            Spacer()
            createButton
                .padding(.trailing, 32)
        }
    }

    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                DiaryImageView(selectedImage: $diaryDataStore.selectedImage)
                .padding(.horizontal, diaryDataStore.selectedImage == nil ? 20 : 0)

                VStack(alignment: .leading, spacing: 20) {
                    // 画像以外に水平方向のpaddingを設定したいので別のStackで管理

                    HStack {
                        InputTitle(title: $diaryDataStore.title)
                        weather
                    }
                    ContentTypeSegmentedPicker(selectedContentType: $selectedContentType)
                    diaryContent
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 100)
        }
    }

    @ViewBuilder
    var weather: some View {
        WeatherSelectButton(selectedWeather: $diaryDataStore.selectedWeather)
            .asyncState(weatherData.phase)
    }

    @ViewBuilder
    var diaryContent: some View {
        switch selectedContentType {
        case .text:
            DiaryTextEditor(bodyText: $diaryDataStore.bodyText)
        case .checkList:
            VStack(spacing: 60) {
                CheckList(diaryDataStore: diaryDataStore)

                NavigationLink {
                    CheckListEditor()
                } label: {
                    CheckListEditButton()
                }
            }
        }
    }

    var createButton: some View {
        Button(actionWithHapticFB: {
            createItemFromInput()
        }) {
            Text("作成")
        }
        .buttonStyle(ActionButtonStyle(isActive: diaryDataStore.canCreate , size: .extraSmall))
        .disabled(!diaryDataStore.canCreate)
    }

    // MARK: Action

    func createItemFromInput() {
        do {
            try diaryDataStore.create()
            bannerState.show(of: .success(message: "新しい日記を追加しました🎉"))
            dismiss()
        } catch {
            bannerState.show(with: error)
        }
    }
}

#if DEBUG

struct CreateDiaryView_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            CreateDiaryView()
        }
        .environmentObject(TextOptions.preview)
        .environmentObject(WeatherData())
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
