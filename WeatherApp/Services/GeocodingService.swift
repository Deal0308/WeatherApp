//
//  GeocodingService.swift
//  WeatherApp
//
//  Builds and performs Open-Meteo geocoding requests for user-entered locations.
//

import Foundation

/// Abstraction that allows the view model to use real or mock geocoding implementations.
protocol GeocodingProviding {
    func locations(for query: String) async throws -> [LocationResult]
}

/// URLSession-backed geocoding service for the Open-Meteo Geocoding API.
struct GeocodingService: GeocodingProviding {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let endpoint = URL(string: "https://geocoding-api.open-meteo.com/v1/search")!

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Searches for matching locations and validates that returned choices include coordinates.
    func locations(for query: String) async throws -> [LocationResult] {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "5"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        #if DEBUG
        print("Geocoding request URL: \(url.absoluteString)")
        #endif

        let data = try await fetchData(from: url)

        do {
            let response = try decoder.decode(GeocodingResponse.self, from: data)
            guard let results = response.results, !results.isEmpty else {
                throw APIError.emptyLocationResults
            }

            let validLocations = results.filter { $0.latitude != nil && $0.longitude != nil }
            guard !validLocations.isEmpty else {
                throw APIError.invalidReturnedData
            }

            return validLocations
        } catch let apiError as APIError {
            throw apiError
        } catch {
            #if DEBUG
            print("Geocoding decoding failed. Body snippet: \(data.debugSnippet)")
            #endif
            throw APIError.decodingFailure
        }
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
