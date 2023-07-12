//
//  WeatherSelectButton.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/06.
//

import SwiftUI
import WeatherKit

struct WeatherSelectButton: View {
    @Binding var selectedWeather: WeatherSymbol
    @State private var isPresentedSelectView: Bool = false
    @State private var isLocationPermissionAlertPresented: Bool = false

    var body: some View {
        Button(actionWithHapticFB: {
            isPresentedSelectView = true
        }) {
            WeatherIcon(weatherSymbolName: selectedWeather.symbol)
        }
        .foregroundColor(.adaptiveBlack)
        .sheet(isPresented: $isPresentedSelectView) {
            WeatherSelect(selectedWeather: $selectedWeather)
                .padding(.horizontal)
                .presentationDetents([.height(300)])
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
    }
}

struct WeatherSelect: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var weatherData: WeatherData

    @Binding var selectedWeather: WeatherSymbol

    @State private var isLocationPermissionTextPresented: Bool = false
    @State private var weatherAttribution: WeatherAttribution?
    private let weatherService = WeatherService()

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
            VStack(spacing: 24) {
                if isLocationPermissionTextPresented {
                    Button(actionWithHapticFB: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }) {
                        Text("「現在位置から取得」するにはこちらをタップして、設定アプリから位置情報を許可してください")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 12))
                    }
                }

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

                    dataFromCurrentLocationButton
                }

                if let weatherAttribution {
                    appleWeatherAttribution(weatherAttribution)
                }
            }
            .padding(.top, 20)
        }
        .scrollIndicators(.hidden)
        .task {
            weatherAttribution = try? await weatherService.attribution
        }
    }
}

private extension WeatherSelect {

    var dataFromCurrentLocationButton: some View {
        Button(actionWithHapticFB: {
            if weatherData.hasTodayWeather {
                selectedWeather = .make(from: weatherData.todayWeather!.symbolName)
            } else {
                do {
                    try  weatherData.load()
                } catch WeatherDataError.noLocationAuth {
                    isLocationPermissionTextPresented = true
                } catch {
                    print(error.localizedDescription)
                    dismiss()
                }
            }
        }) {
            weatherItem(
                imageName: "arrow.2.squarepath",
                title: "現在位置から取得"
            )
        }
    }

    func weatherItem(imageName: String, title: String) -> some View {
        VStack(alignment: .center, spacing: 16) {
            WeatherIcon(weatherSymbolName: imageName)
            Text(title)
        }
        .foregroundColor(.adaptiveBlack)
    }

    func appleWeatherAttribution(_ weatherAttribution: WeatherAttribution) -> some View {
        HStack {
            AsyncImage( url: weatherAttribution.combinedMarkLightURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 12)
            } placeholder: {
                ProgressView()
            }
            Button("Link") {
                UIApplication.shared.open(weatherAttribution.legalPageURL)
            }
            .tint(.blue)
        }
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

