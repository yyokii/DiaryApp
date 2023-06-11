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

    @StateObject private var diaryDataStore: DiaryDataStore = DiaryDataStore()

    @State var isPresentedDatePicker: Bool = false

    @FocusState private var focusedField: FocusedField?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    private let dateRange: ClosedRange<Date> = Date(timeIntervalSince1970: 0)...Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AddPhoto(selectedImage: $diaryDataStore.selectedImage)

                    VStack(spacing: 20) {
                        date
                        weather
                        checkList
                        InputTitle(title: $diaryDataStore.title, focusedField: _focusedField)
                        InputBody(bodyText: $diaryDataStore.bodyText, focusedField: _focusedField)
                        createButton
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
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

    var date: some View {
        Button(action: {
            isPresentedDatePicker.toggle()
        }, label: {
            HStack {
                Text(diaryDataStore.selectedDate, style: .date)
                Image(systemName: "pencil")
            }
            .font(.system(size: 20))
        })
        .foregroundColor(.adaptiveBlack)
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

    var createButton: some View {
        Button("Create") {
            createItemFromInput()
        }
        .buttonStyle(ActionButtonStyle(isActive: (diaryDataStore.canCreate)))
        .disabled(!diaryDataStore.canCreate)
    }

    var checkList: some View {
        CheckList(diaryDataStore: diaryDataStore)
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
        CreateDiaryView()
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
