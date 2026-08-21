//
//  SavedLocationStore.swift
//  WeatherApp
//
//  Provides Codable/UserDefaults-backed persistence operations for favorite locations.
//

import Foundation

/// Repository that keeps saved-location persistence logic out of SwiftUI views.
final class SavedLocationStore {
    private let userDefaults: UserDefaults
    private let storageKey = "SavedLocations"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func savedLocations() throws -> [SavedLocation] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        do {
            return try decoder.decode([SavedLocation].self, from: data)
                .sorted { $0.dateSaved > $1.dateSaved }
        } catch {
            throw APIError.persistenceFailure
        }
    }

    func isSaved(location: LocationResult) throws -> Bool {
        try savedLocations().contains { $0.stableKey == location.stableKey }
    }

    @discardableResult
    func save(location: LocationResult) throws -> SavedLocation {
        var locations = try savedLocations()
        if let existingLocation = locations.first(where: { $0.stableKey == location.stableKey }) {
            return existingLocation
        }

        let savedLocation = try SavedLocation(location: location)
        locations.insert(savedLocation, at: 0)
        try persist(locations)
        return savedLocation
    }

    func remove(location: LocationResult) throws {
        var locations = try savedLocations()
        locations.removeAll { $0.stableKey == location.stableKey }
        try persist(locations)
    }

    func delete(_ savedLocation: SavedLocation) throws {
        var locations = try savedLocations()
        locations.removeAll { $0.id == savedLocation.id || $0.stableKey == savedLocation.stableKey }
        try persist(locations)
    }

    private func persist(_ locations: [SavedLocation]) throws {
        do {
            let data = try encoder.encode(locations)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            throw APIError.persistenceFailure
        }
    }
}
