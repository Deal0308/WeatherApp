//
//  SavedLocation.swift
//  WeatherApp
//
//  Defines the Codable model used to persist favorite weather locations.
//

import Foundation

/// A user-saved weather location with stable identity and coordinates.
struct SavedLocation: Codable, Equatable, Identifiable {
    let id: UUID
    let stableKey: String
    let openMeteoID: Int?
    let locationName: String
    let administrativeRegion: String?
    let country: String
    let latitude: Double
    let longitude: Double
    let timeZone: String?
    let dateSaved: Date

    init(
        id: UUID = UUID(),
        stableKey: String,
        openMeteoID: Int?,
        locationName: String,
        administrativeRegion: String?,
        country: String,
        latitude: Double,
        longitude: Double,
        timeZone: String?,
        dateSaved: Date = Date()
    ) {
        self.id = id
        self.stableKey = stableKey
        self.openMeteoID = openMeteoID
        self.locationName = locationName
        self.administrativeRegion = administrativeRegion
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
        self.dateSaved = dateSaved
    }

    init(location: LocationResult) throws {
        guard let latitude = location.latitude, let longitude = location.longitude else {
            throw APIError.invalidSelectedLocation
        }

        self.init(
            stableKey: location.stableKey,
            openMeteoID: location.openMeteoID,
            locationName: location.name,
            administrativeRegion: location.admin1,
            country: location.country,
            latitude: latitude,
            longitude: longitude,
            timeZone: location.timeZone
        )
    }

    var regionDescription: String {
        [administrativeRegion, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var coordinateText: String {
        "\(latitude.formatted(.number.precision(.fractionLength(2...4)))), \(longitude.formatted(.number.precision(.fractionLength(2...4))))"
    }

    var locationResult: LocationResult {
        LocationResult(
            openMeteoID: openMeteoID,
            name: locationName,
            latitude: latitude,
            longitude: longitude,
            country: country,
            admin1: administrativeRegion,
            timeZone: timeZone
        )
    }
}
