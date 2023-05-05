//
//  AddDiaryView.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/02.
//

import PhotosUI
import SwiftUI

struct AddDiaryView: View {
    @StateObject private var weatherData = WeatherData()

    @State private var selectedDate = Date()
    @State private var title = ""
    @State private var bodyText = ""
    @State private var selectedWeather = ""
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    addImage

                    VStack(spacing: 20) {
                        date
                        weather
                        inputEmoji
                        diaryBody
                        createButton
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .onChange(of: selectedPickerItem) { _ in
            Task {
                if let data = try? await selectedPickerItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let resizedImage = uiImage.resizeImage(to: imageSize),
                   let rotatedImage = resizedImage.reorientToUp() {
                    selectedImage = rotatedImage
                }
            }
        }
        .onAppear{
            // TODO: 移動させてもいいかも
            weatherData.requestLocationAuth()
        }
    }

}

private extension AddDiaryView {
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
                    .frame(height: imageSize.height)

            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(height: imageSize.height)
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

    var inputEmoji: some View {
        TextField("title", text: $title)
            .font(.system(size: 32))
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var weather: some View {
        if Calendar.current.isDateInToday(selectedDate),
           let todayWeather = weatherData.todayWeather {
            Image(systemName: todayWeather.symbolName)
                .asyncState(weatherData.phase)
        } else {
            Picker("select weather", selection: $selectedWeather) {
                ForEach(dayWeatherSymbolNames, id: \.self) { symbolName in
                    Image(systemName: symbolName)
                }
            }
        }
    }

    var diaryBody: some View {
        TextField("Write your life", text: $bodyText ,axis: .vertical)
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
            let diaryItem = Item()
            // TODO: save
        }
        .buttonStyle(ActionButtonStyle())
    }
}

#if DEBUG

struct AddDiaryView_Previews: PreviewProvider {

    static var content: some View {
        AddDiaryView()
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
