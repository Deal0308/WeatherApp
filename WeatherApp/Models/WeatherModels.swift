//
//  WeatherModels.swift
//  WeatherApp
//
//  Defines weather forecast decoding models and presentation helpers for WMO weather codes.
//

import Foundation

/// Top-level response returned by the Open-Meteo Forecast API.
struct WeatherResponse: Decodable {
    let current: CurrentWeather?
    let daily: DailyWeather?
}

/// Current weather values required by the app.
struct CurrentWeather: Decodable, Equatable {
    let temperature: Double?
    let humidity: Int?
    let weatherCode: Int?
    let windSpeed: Double?
    let isDay: Int?

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case humidity = "relative_humidity_2m"
        case weatherCode = "weather_code"
        case windSpeed = "wind_speed_10m"
        case isDay = "is_day"
    }
}

/// Daily forecast arrays returned by Open-Meteo.
struct DailyWeather: Decodable, Equatable {
    let time: [String]?
    let weatherCodes: [Int]?
    let maximumTemperatures: [Double]?
    let minimumTemperatures: [Double]?
    let maximumPrecipitationProbabilities: [Int]?

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCodes = "weather_code"
        case maximumTemperatures = "temperature_2m_max"
        case minimumTemperatures = "temperature_2m_min"
        case maximumPrecipitationProbabilities = "precipitation_probability_max"
    }
}

/// Human-readable weather state paired with an SF Symbol.
enum WeatherConditionKind: Equatable {
    case clear
    case mainlyClear
    case partlyCloudy
    case overcast
    case fog
    case drizzle
    case freezingDrizzle
    case rain
    case freezingRain
    case snow
    case rainShowers
    case snowShowers
    case thunderstorms
    case unknown
}

/// Human-readable weather state paired with an SF Symbol and a reusable condition kind.
struct WeatherCondition: Equatable {
    let kind: WeatherConditionKind
    let description: String
    let symbolName: String

    static func condition(for code: Int) -> WeatherCondition {
        switch code {
        case 0:
            return WeatherCondition(kind: .clear, description: "Clear sky", symbolName: "sun.max.fill")
        case 1:
            return WeatherCondition(kind: .mainlyClear, description: "Mainly clear", symbolName: "sun.min.fill")
        case 2:
            return WeatherCondition(kind: .partlyCloudy, description: "Partly cloudy", symbolName: "cloud.sun.fill")
        case 3:
            return WeatherCondition(kind: .overcast, description: "Overcast", symbolName: "cloud.fill")
        case 45, 48:
            return WeatherCondition(kind: .fog, description: "Fog", symbolName: "cloud.fog.fill")
        case 51, 53, 55:
            return WeatherCondition(kind: .drizzle, description: "Drizzle", symbolName: "cloud.drizzle.fill")
        case 56, 57:
            return WeatherCondition(kind: .freezingDrizzle, description: "Freezing drizzle", symbolName: "cloud.sleet.fill")
        case 61, 63, 65:
            return WeatherCondition(kind: .rain, description: "Rain", symbolName: "cloud.rain.fill")
        case 66, 67:
            return WeatherCondition(kind: .freezingRain, description: "Freezing rain", symbolName: "cloud.sleet.fill")
        case 71, 73, 75, 77:
            return WeatherCondition(kind: .snow, description: "Snow", symbolName: "snowflake")
        case 80, 81, 82:
            return WeatherCondition(kind: .rainShowers, description: "Rain showers", symbolName: "cloud.heavyrain.fill")
        case 85, 86:
            return WeatherCondition(kind: .snowShowers, description: "Snow showers", symbolName: "cloud.snow.fill")
        case 95, 96, 99:
            return WeatherCondition(kind: .thunderstorms, description: "Thunderstorms", symbolName: "cloud.bolt.rain.fill")
        default:
            return WeatherCondition(kind: .unknown, description: "Unknown conditions", symbolName: "questionmark.circle.fill")
        }
    }
}

/// Complete weather payload returned by the weather service after validation.
struct WeatherReport: Equatable {
    let current: CurrentWeather
    let dailyForecasts: [DailyForecast]
}

/// Presentation-ready weather data published by the view model.
struct WeatherSummary: Equatable, Identifiable {
    let id = UUID()
    let locationStableKey: String
    let locationName: String
    let regionDescription: String
    let latitude: Double
    let longitude: Double
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let condition: WeatherCondition
    let isDay: Bool

    var temperatureText: String {
        "\(Int(temperature.rounded()))°F"
    }

    var humidityText: String {
        "\(humidity)%"
    }

    var windSpeedText: String {
        "\(windSpeed.formatted(.number.precision(.fractionLength(0...1)))) mph"
    }
}

/// Presentation-ready forecast data for one day in the five-day forecast.
struct DailyForecast: Equatable, Identifiable {
    let id: String
    let date: Date
    let weatherCode: Int
    let condition: WeatherCondition
    let maximumTemperature: Double
    let minimumTemperature: Double
    let maximumPrecipitationProbability: Int

    var dayText: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        return date.formatted(.dateTime.weekday(.wide))
    }

    var dateText: String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    var highTemperatureText: String {
        "High \(Int(maximumTemperature.rounded()))°"
    }

    var lowTemperatureText: String {
        "Low \(Int(minimumTemperature.rounded()))°"
    }

    var precipitationText: String {
        "\(maximumPrecipitationProbability)%"
    }

    var accessibilityDescription: String {
        "\(dayText), \(condition.description), high \(Int(maximumTemperature.rounded())) degrees, low \(Int(minimumTemperature.rounded())) degrees, \(maximumPrecipitationProbability) percent chance of precipitation."
    }

    static func forecasts(from dailyWeather: DailyWeather) throws -> [DailyForecast] {
        guard let times = dailyWeather.time,
              let weatherCodes = dailyWeather.weatherCodes,
              let maximumTemperatures = dailyWeather.maximumTemperatures,
              let minimumTemperatures = dailyWeather.minimumTemperatures,
              let maximumPrecipitationProbabilities = dailyWeather.maximumPrecipitationProbabilities else {
            throw APIError.invalidForecastData
        }

        let forecastCount = [
            times.count,
            weatherCodes.count,
            maximumTemperatures.count,
            minimumTemperatures.count,
            maximumPrecipitationProbabilities.count
        ].min() ?? 0

        guard forecastCount > 0 else {
            throw APIError.invalidForecastData
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        return try (0..<forecastCount).map { index in
            guard let date = formatter.date(from: times[index]) else {
                throw APIError.invalidForecastData
            }

            let code = weatherCodes[index]
            return DailyForecast(
                id: times[index],
                date: date,
                weatherCode: code,
                condition: WeatherCondition.condition(for: code),
                maximumTemperature: maximumTemperatures[index],
                minimumTemperature: minimumTemperatures[index],
                maximumPrecipitationProbability: maximumPrecipitationProbabilities[index]
            )
        }
    }
}
