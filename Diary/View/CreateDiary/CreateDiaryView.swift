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
    @State private var isPresentedTextEditor: Bool = false
    @State private var selectedContentType: DiaryContentType = .text

    @FocusState private var focusedField: FocusedField?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    private let dateRange: ClosedRange<Date> = Date(timeIntervalSince1970: 0)...Date()

    var body: some View {
        ZStack {
            VStack {
                header
                    .padding(.top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        DiaryImageView(
                            selectedImage: $diaryDataStore.selectedImage,
                            isEditing: true
                        )
                            .padding(.horizontal, diaryDataStore.selectedImage == nil ? 20 : 0)

                        VStack(alignment: .leading, spacing: 20) {
                            // 画像以外に水平方向のpaddingを設定したいので別のStackで管理

                            HStack {
                                InputTitle(title: $diaryDataStore.title, focusedField: _focusedField)
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

            if isPresentedTextEditor {
                DiaryTextEditor(
                    bodyText: $diaryDataStore.bodyText,
                    isPresented: $isPresentedTextEditor
                )
            }
        }
        .onSubmit {
            if focusedField == .title {
                focusedField = .body
            } else {
                focusedField = nil
            }
        }
        .onReceive(weatherData.$todayWeather , perform: { todayWeather in
            guard let todayWeather else { return }
            diaryDataStore.selectedWeather = .make(from: todayWeather.symbolName)
        })
        .onAppear{
            // TODO: 移動させてもいいかも
            weatherData.requestLocationAuth()
        }
    }
}

private extension CreateDiaryView {

    // MARK: View

    var header: some View {
        HStack {
            date
                .padding(.leading)
            Spacer()
            createButton
                .padding(.trailing)
        }
    }

    var date: some View {
        Button(action: {
            isPresentedDatePicker.toggle()
        }, label: {
            HStack {
                HStack {
                    Image(systemName: "calendar")
                    Text(diaryDataStore.selectedDate, style: .date)
                        .bold()
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.appSecondary_100)
                }
                Text("の日記")
                    .foregroundColor(.adaptiveBlack)
            }
            .font(.system(size: 20))
        })
        .foregroundColor(.appBlack)
        .sheet(isPresented: $isPresentedDatePicker) {
            /*
             https://developer.apple.com/forums/thread/725965

             下部に限らずDatePickerを表示している状態または閉じてすぐに他のsheetを表示させるとPresentaionエラーとなり、
             以降Viewが再生成？されるまでSheetは表示されない。（iOS 16.4.1(a)実機で検証）
             そのため、DatePickerをそのまま利用するのではなくsheetで表示している。
             */
            DatePicker("", selection: $diaryDataStore.selectedDate, displayedComponents: [.date])
                .padding(.horizontal)
                .datePickerStyle(GraphicalDatePickerStyle())
                .presentationDetents([.medium])
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
            InputBodyButton(
                bodyText: $diaryDataStore.bodyText) {
                    isPresentedTextEditor = true
                }
        case .checkList:
            CheckList(diaryDataStore: diaryDataStore, isEditable: .constant(true))
        }
    }

    var createButton: some View {
        Button(actionWithHapticFB: {
            createItemFromInput()
        }) {
            HStack {
                Text("作成")
                    .bold()
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                        .fill(Color.appPrimary)
                    )
            }
        }
        .disabled(!diaryDataStore.canCreate)
    }

    // MARK: Action

    func createItemFromInput() {
        do {
            try diaryDataStore.create()
            bannerState.show(of: .success(message: "Add diary🎉"))
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
                .environmentObject(TextOptions.preview)
                .environmentObject(WeatherData())
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
