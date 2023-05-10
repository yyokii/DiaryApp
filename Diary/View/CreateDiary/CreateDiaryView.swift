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

    @StateObject private var weatherData = WeatherData()

    // modelに置き換える
    @State private var selectedDate = Date()
    @State private var title = ""
    @State private var bodyText = ""
    @State private var selectedWeather = ""
    @State private var selectedImage: UIImage?

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
                    AddPhoto(selectedImage: $selectedImage)

                    VStack(spacing: 20) {
                        date
                        weather
                        InputTitle(title: $title, focusedField: _focusedField)
                        InputBody(bodyText: $bodyText, focusedField: _focusedField)
                        createButton
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .onSubmit {
            if focusedField == .title {
                focusedField = .body
            } else {
                focusedField = nil
            }
        }
        .onAppear{
            // TODO: 移動させてもいいかも
            weatherData.requestLocationAuth()
        }
    }
}

private extension CreateDiaryView {

    // MARK: Validation

    var validTitle: Bool {
        title.count >= InputTitle.titleCount.min &&
        title.count <= InputTitle.titleCount.max
    }

    var validBody: Bool {
        bodyText.count >= InputBody.bodyCount.min &&
        bodyText.count <= InputBody.bodyCount.max
    }

    // MARK: View

    var date: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            in: dateRange,
            displayedComponents: [.date]
        )
        .labelsHidden()
    }

    @ViewBuilder
    var weather: some View {
        if Calendar.current.isDateInToday(selectedDate) {
            // TODO: この時も変更できた方がいい
            Image(systemName: weatherData.todayWeather?.symbolName ?? "")
                .resizable()
                .scaledToFit()
                .frame(width:24)
                .asyncState(weatherData.phase)
        } else {
            WeatherPicker(selectedWeather: $selectedWeather)
        }
    }

    var createButton: some View {
        Button("Create") {
            createItemFromInput()
        }
        .buttonStyle(ActionButtonStyle(isActive: (validTitle && validBody))) // TODO: activeとdisable連動させる？
    }

    // MARK: Action

    func createItemFromInput() {
        var weather: String
        if Calendar.current.isDateInToday(selectedDate),
           let todayWeather = weatherData.todayWeather {
            weather = todayWeather.symbolName
        } else {
            weather = selectedWeather
        }

        var imageData: Data?
        if let selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.5)
        }

        do {
            try Item.create(
                date: selectedDate,
                title: title,
                body: bodyText,
                weather: weather,
                imageData: imageData
            )
            dismiss()
        } catch {
            // TODO: handle error
        }
    }
}

#if DEBUG

struct CreateDiaryView_Previews: PreviewProvider {

    static var content: some View {
        CreateDiaryView()
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
