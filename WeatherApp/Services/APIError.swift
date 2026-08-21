//
//  APIError.swift
//  WeatherApp
//
//  Provides user-facing networking and decoding errors shared by the API services.
//

import Foundation

/// Errors produced while building requests, fetching responses, decoding JSON, or validating API data.
enum APIError: LocalizedError, Equatable {
    case invalidURL
    case transportFailure
    case invalidHTTPResponse
    case unsuccessfulStatusCode(Int)
    case emptyLocationResults
    case invalidSelectedLocation
    case decodingFailure
    case invalidReturnedData
    case invalidForecastData
    case persistenceFailure

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The weather request could not be created. Try another search."
        case .transportFailure:
            return "The network request failed. Check your connection and try again."
        case .invalidHTTPResponse:
            return "The weather service returned an invalid response. Try again later."
        case .unsuccessfulStatusCode:
            return "The weather service is temporarily unavailable. Try again later."
        case .emptyLocationResults:
            return "No matching location was found. Check the spelling and try again."
        case .invalidSelectedLocation:
            return "The selected location is missing coordinates. Choose another result."
        case .decodingFailure:
            return "The weather service returned data the app could not read."
        case .invalidReturnedData:
            return "The weather service returned incomplete weather data. Try again later."
        case .invalidForecastData:
            return "The forecast service returned incomplete daily forecast data."
        case .persistenceFailure:
            return "Saved locations could not be updated. Try again."
        }
    }
}
