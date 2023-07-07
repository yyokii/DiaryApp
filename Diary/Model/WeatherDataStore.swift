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
                if self.locationService.authStatus == .authorizedAlways || self.locationService.authStatus == .authorizedWhenInUse, let location = location {
                    self.location = location
                    Task.detached(priority: .userInitiated) {
                        await self.loadDailyForecast(for: location)
                    }
                } else {
                    // 位置情報を許可していない等で位置情報を利用できない場合
                    self.phase = .success(Date())
                }
            }
            .store(in: &cancellables)
    }

    public func load() throws {
        let authorized = locationService.authStatus == .authorizedAlways || locationService.authStatus == .authorizedWhenInUse
        if let location, authorized {
            Task.detached(priority: .userInitiated) {
                await self.loadDailyForecast(for: location)
            }
        } else if !authorized {
            throw WeatherDataError.noLocationAuth
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
    case noLocationAuth

    public var errorDescription: String? {
        switch self {
        case .notFoundTodayWeatherError:
            return "今日の天気を取得できませんでした"
        case .noLocationAuth:
            return "位置情報の取得が許可されていません"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .notFoundTodayWeatherError:
            return "エラーが発生しました、再度お試しください"
        case .noLocationAuth:
            return "位置情報の取得が許可されていません"
        }
    }
}
