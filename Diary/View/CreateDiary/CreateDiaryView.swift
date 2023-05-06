//
//  CreateDiaryView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import PhotosUI
import SwiftUI

struct CreateDiaryView: View {
    @StateObject private var weatherData = WeatherData()

    @State private var selectedDate = Date()
    @State private var title = ""
    @State private var bodyText = ""
    @State private var selectedWeather = ""
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    enum FocusedField {
        case title, body
    }
    @FocusState private var focusedField: FocusedField?

    private let imageSize: CGSize = .init(width: 300, height: 300)
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    private let dateRange: ClosedRange<Date> = Date(timeIntervalSince1970: 0)...Date()
    private let dayWeatherSymbolNames = [
        "sun.min", "sun.max",
        "cloud.sun", "cloud.sun.rain", "cloud.sun.bolt", "cloud", "cloud.drizzle", "cloud.rain", "cloud.heavyrain", "cloud.fog", "cloud.hail", "cloud.snow", "cloud.sleet", "cloud.bolt", "cloud.bolt.rain",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    addImage

                    VStack(spacing: 20) {
                        date
                        weather
                        inputTitle
                        diaryBody
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
        .onChange(of: selectedPickerItem) { pickerItem in
            updateSelectedImage(to: pickerItem)
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
        title.count > 0 && title.count <= 10
    }

    var validBody: Bool {
        bodyText.count > 0 && bodyText.count <= 1000
    }

    // MARK: View

    var addImage: some View {
        ZStack() {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .topTrailing, content: {
                        Button {
                            self.selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundStyle(.white, .black)
                        }
                        .padding(.top, 4)
                        .padding(.trailing, 4)
                    })
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(height: 300)
            }

            if selectedImage == nil {
                PhotosPicker(selection: $selectedPickerItem) {
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    var date: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            in: dateRange,
            displayedComponents: [.date]
        )
        .labelsHidden()
    }

    var inputTitle: some View {
        TextField("タイトル（1~10文字）", text: $title)
            .font(.system(size: 24))
            .multilineTextAlignment(.center)
            .focused($focusedField, equals: .title)
    }

    @ViewBuilder
    var weather: some View {
        if Calendar.current.isDateInToday(selectedDate) {
            Image(systemName: weatherData.todayWeather?.symbolName ?? "")
                .resizable()
                .scaledToFit()
                .frame(width:24)
                .asyncState(weatherData.phase)
        } else {
            Picker("weather", selection: $selectedWeather) {
                ForEach(dayWeatherSymbolNames, id: \.self) { symbolName in
                    Image(systemName: symbolName)
                }
            }
        }
    }

    var diaryBody: some View {
        TextField(
            "思い出 📝（1000文字以内）",
            text: $bodyText,
            axis: .vertical
        )
        .focused($focusedField, equals: .body)
        .font(.system(size: 16))
        .frame(height: 250, alignment: .top)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
                .padding(-5)
        )
    }

    var createButton: some View {
        Button("Create") {
            createItemFromInput()
        }
        .buttonStyle(ActionButtonStyle(isActive: (validTitle && validBody)))
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
        } catch {
            // TODO: handle error
        }
    }

    func updateSelectedImage(to pickerItem: PhotosPickerItem?) {
        Task {
            if let data = try? await pickerItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data),
               let resizedImage = uiImage.resizeImage(to: imageSize),
               let rotatedImage = resizedImage.reorientToUp() {
                selectedImage = rotatedImage
            }
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
