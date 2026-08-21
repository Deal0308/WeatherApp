//
//  WeatherService.swift
//  WeatherApp
//
//  Builds and performs Open-Meteo forecast requests for validated coordinates.
//

import Foundation

/// Abstraction that allows the view model to use real or mock weather implementations.
protocol WeatherProviding {
    func weather(latitude: Double, longitude: Double) async throws -> WeatherReport
}

/// URLSession-backed weather service for the Open-Meteo Forecast API.
struct WeatherService: WeatherProviding {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let endpoint = URL(string: "https://api.open-meteo.com/v1/forecast")!

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Fetches current weather and a five-day forecast for coordinates.
    func weather(latitude: Double, longitude: Double) async throws -> WeatherReport {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: coordinateQueryValue(latitude)),
            URLQueryItem(name: "longitude", value: coordinateQueryValue(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "5")
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        #if DEBUG
        print("Weather request URL: \(url.absoluteString)")
        #endif

        let data = try await fetchData(from: url)

        do {
            let response = try decoder.decode(WeatherResponse.self, from: data)
            guard let current = response.current,
                  current.temperature != nil,
                  current.humidity != nil,
                  current.weatherCode != nil,
                  current.windSpeed != nil,
                  let daily = response.daily else {
                throw APIError.invalidReturnedData
            }

            let dailyForecasts = try DailyForecast.forecasts(from: daily)
            return WeatherReport(current: current, dailyForecasts: dailyForecasts)
        } catch let apiError as APIError {
            throw apiError
        } catch {
            #if DEBUG
            print("Weather decoding failed. Body snippet: \(data.debugSnippet)")
            #endif
            throw APIError.decodingFailure
        }
    }

    private func coordinateQueryValue(_ coordinate: Double) -> String {
        String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), coordinate)
    }

    private func fetchData(from url: URL) async throws -> Data {
        let response: URLResponse
        let data: Data

        do {
            (data, response) = try await session.data(from: url)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIError.transportFailure
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidHTTPResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.unsuccessfulStatusCode(httpResponse.statusCode)
        }

        return data
    }
}

private extension Data {
    var debugSnippet: String {
        String(decoding: prefix(500), as: UTF8.self)
    }
}
