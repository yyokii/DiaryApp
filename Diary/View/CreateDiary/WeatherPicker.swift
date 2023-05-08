//
//  WeatherPicker.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI

struct WeatherPicker: View {
    @Binding var selectedWeather: String

    private let dayWeatherSymbolNames = [
        "sun.min", "sun.max",
        "cloud.sun", "cloud.sun.rain", "cloud.sun.bolt", "cloud", "cloud.drizzle", "cloud.rain", "cloud.heavyrain", "cloud.fog", "cloud.hail", "cloud.snow", "cloud.sleet", "cloud.bolt", "cloud.bolt.rain",
    ]

    var body: some View {
        Picker("weather", selection: $selectedWeather) {
            ForEach(dayWeatherSymbolNames, id: \.self) { symbolName in
                Image(systemName: symbolName)
            }
        }
    }
}
