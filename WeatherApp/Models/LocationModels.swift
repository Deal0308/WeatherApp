//
//  LocationModels.swift
//  WeatherApp
//
//  Defines the focused Codable models used to decode Open-Meteo geocoding results.
//

import Foundation

/// Top-level response returned by the Open-Meteo Geocoding API.
struct GeocodingResponse: Decodable {
    let results: [LocationResult]?
}

/// A single geocoding match containing only the fields the app displays or needs for weather lookup.
struct LocationResult: Decodable, Equatable, Identifiable {
    let openMeteoID: Int?
    let name: String
    let latitude: Double?
    let longitude: Double?
    let country: String
    let admin1: String?
    let timeZone: String?
    let population: Int?

    enum CodingKeys: String, CodingKey {
        case openMeteoID = "id"
        case name
        case latitude
        case longitude
        case country
        case admin1
        case timeZone = "timezone"
        case population
    }

    init(
        openMeteoID: Int? = nil,
        name: String,
        latitude: Double?,
        longitude: Double?,
        country: String,
        admin1: String? = nil,
        timeZone: String? = nil,
        population: Int? = nil
    ) {
        self.openMeteoID = openMeteoID
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.admin1 = admin1
        self.timeZone = timeZone
        self.population = population
    }

    var id: String {
        stableKey
    }

    var coordinateDescription: String {
        [admin1, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var detailDescription: String {
        let populationText = population.map { "Population \($0.formatted())" }
        return [coordinateDescription, timeZone, populationText]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
    }

    var coordinateText: String {
        guard let latitude, let longitude else {
            return "Coordinates unavailable"
        }

        return "\(latitude.formatted(.number.precision(.fractionLength(2...4)))), \(longitude.formatted(.number.precision(.fractionLength(2...4))))"
    }

    var stableKey: String {
        Self.stableKey(openMeteoID: openMeteoID, name: name, latitude: latitude, longitude: longitude)
    }

    static func stableKey(openMeteoID: Int?, name: String, latitude: Double?, longitude: Double?) -> String {
        if let openMeteoID {
            return "open-meteo-\(openMeteoID)"
        }

        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let latitudeValue = latitude.map { String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), $0) } ?? "unknown-lat"
        let longitudeValue = longitude.map { String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), $0) } ?? "unknown-lon"
        return "\(normalizedName)-\(latitudeValue)-\(longitudeValue)"
    }
}
