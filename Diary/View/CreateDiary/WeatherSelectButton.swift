//
//  WeatherSelectButton.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI

struct WeatherSelectButton: View {
    @Binding var selectedWeather: WeatherSymbol
    @State private var isPresentedSelectView: Bool = false

    var body: some View {
        Button(actionWithHapticFB: {
            isPresentedSelectView = true
        }) {
            WeatherIcon(weatherSymbolName: selectedWeather.symbol)
        }
        .foregroundColor(.adaptiveBlack)
        .sheet(isPresented: $isPresentedSelectView) {
            WeatherSelect(selectedWeather: $selectedWeather)
                .presentationDetents([.height(280)])
        }
    }
}

struct WeatherIcon: View {
    public static var itemWidth: CGFloat = 50
    let weatherSymbolName: String

    var body: some View {
        Circle()
            .fill(Color.adaptiveWhite)
            .frame(width: WeatherIcon.itemWidth)
            .overlay {
                Image(systemName: weatherSymbolName)
                    .font(.system(size: 24))
            }
            .adaptiveShadow()
    }
}

struct WeatherSelect: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var weatherData: WeatherData

    @Binding var selectedWeather: WeatherSymbol

    private static let itemWidth: CGFloat = 70
    private let columns: [GridItem] = Array(
        repeating: .init(
            .fixed(itemWidth),
            spacing: 40,
            alignment: .top
        ),
        count: 3
    )

    private let weatherSymbols: [WeatherSymbol] = [ .sun, .cloud, .rain, .snow, .wind]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(weatherSymbols, id: \.symbol) { weatherSymbol in
                    Button(actionWithHapticFB: {
                        selectedWeather = weatherSymbol
                        dismiss()
                    }) {
                        weatherItem(
                            imageName: weatherSymbol.symbol,
                            title: weatherSymbol.name
                        )
                    }
                }

                Button(actionWithHapticFB: {
                    if weatherData.hasTodayWeather {
                        selectedWeather = .make(from: weatherData.todayWeather!.symbolName)
                    } else {
                        weatherData.load()
                    }
                    dismiss()
                }) {
                    weatherItem(
                        imageName: "arrow.2.squarepath",
                        title: "現在位置から取得"
                    )
                }
            }
            .padding(30)
        }
    }
}

private extension WeatherSelect {
    func weatherItem(imageName: String, title: String) -> some View {
        VStack(alignment: .center, spacing: 16) {
            WeatherIcon(weatherSymbolName: imageName)
            Text(title)
        }
        .foregroundColor(.adaptiveBlack)
    }
}

#if DEBUG

struct WeatherPicker_Previews: PreviewProvider {

    static var content: some View {
        NavigationStack {
            WeatherSelectButton(selectedWeather: .constant(.sun))
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

