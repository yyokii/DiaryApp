//
//  WeatherDataStore.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/26.
//

import Combine
import CoreLocation
import WeatherKit

/**
 The data provider that loads weather forecast data.
 */
@MainActor
public class WeatherData: ObservableObject {

    @Published public var phase: AsyncStatePhase = .initial
    @Published public var todayWeather: DayWeather?
    public var hasTodayWeather: Bool {
        guard let todayWeather else {
            return false
        }
        return Calendar.current.isDateInToday(todayWeather.date)
    }

    private var location: CLLocation?

    private let service = WeatherService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        locationService.$location
            .sink { location in
                if let location = location {
                    self.location = location
                    Task.detached(priority: .userInitiated) {
                        await self.loadDailyForecast(for: location)
                    }
                }
            }
            .store(in: &cancellables)
    }

    public func load() {
        if let location {
            Task.detached(priority: .userInitiated) {
                await self.loadDailyForecast(for: location)
            }
        }
    }

    public func requestLocationAuth() {
        locationService.requestWhenInUseAuthorization()
    }

    private func loadDailyForecast(for location: CLLocation) async {
        phase = .loading
        let dailyForecast = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: location,
                including: .daily
            )
            return forecast
        }.value

        if let todayWeather = dailyForecast?.first(where: { weather in
            Calendar.current.isDateInToday(weather.date)
        }) {
            self.todayWeather = todayWeather
            phase = .success(Date())
        } else {
            phase = .failure(WeatherDataError.notFoundTodayWeatherError)
        }
    }
}

public enum WeatherDataError: Error, LocalizedError {
    case notFoundTodayWeatherError

    public var errorDescription: String? {
        switch self {
        case .notFoundTodayWeatherError:
            return "Failed to fetch today weather."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notFoundTodayWeatherError:
            return "Sorry, please try again later."
        }
    }
}
