//
//  WeatherSymbol.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/05/18.
//

enum WeatherSymbol: Equatable {
    case sun
    case cloud
    case rain
    case snow
    case wind
    case custom(symbol: String, name: String)

    static var weatherCases: [WeatherSymbol] = [.sun, .cloud, .rain, .snow, .wind]

    var symbol: String {
        switch self {
        case .sun:
            return "sun.max"
        case .cloud:
            return "cloud"
        case .rain:
            return "cloud.rain"
        case .snow:
            return "cloud.snow"
        case .wind:
            return "wind"
        case .custom(let symbol, _):
            return symbol
        }
    }

    var name: String {
        switch self {
        case .sun:
            return "晴れ"
        case .cloud:
            return "曇り"
        case .rain:
            return "雨"
        case .snow:
            return "雪"
        case .wind:
            return "強風"
        case .custom(_, let name):
            return name
        }
    }

    static func make(from symbol: String) -> WeatherSymbol {
        for case let weatherCase in WeatherSymbol.weatherCases {
            if weatherCase.symbol == symbol {
                return weatherCase
            }
        }

        return .custom(symbol: symbol, name: "")
    }
}
