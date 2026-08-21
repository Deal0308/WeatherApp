//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Coordinates search, selection, weather loading, and favorite-location state for SwiftUI views.
//

import Combine
import Foundation

/// Main-actor view model that manages all presentation state for SkyCast.
@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isShowingLocationResults = false
    @Published private(set) var isLoading = false
    @Published private(set) var weatherSummary: WeatherSummary?
    @Published private(set) var dailyForecasts: [DailyForecast] = []
    @Published private(set) var locationChoices: [LocationResult] = []
    @Published private(set) var selectedLocation: LocationResult?
    @Published private(set) var savedLocations: [SavedLocation] = []
    @Published private(set) var isSelectedLocationSaved = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastQuery: String?

    private let geocodingService: GeocodingProviding
    private let weatherService: WeatherProviding
    private var savedLocationStore: SavedLocationStore?
    private var currentSearchTask: Task<Void, Never>?
    private var activeSearchID: UUID?

    var canSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    var isEmptyStateVisible: Bool {
        !isLoading && weatherSummary == nil && errorMessage == nil && locationChoices.isEmpty
    }

    var canRetry: Bool {
        selectedLocation != nil || lastQuery != nil
    }

    init(
        geocodingService: GeocodingProviding? = nil,
        weatherService: WeatherProviding? = nil,
        savedLocationStore: SavedLocationStore? = nil
    ) {
        self.geocodingService = geocodingService ?? GeocodingService()
        self.weatherService = weatherService ?? WeatherService()
        self.savedLocationStore = savedLocationStore ?? SavedLocationStore()
        refreshSavedLocations()
    }

    /// Starts geocoding for the trimmed query and defers weather loading until a location is selected.
    func searchLocations() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            errorMessage = "Enter a city or location to search."
            return
        }

        guard !isLoading else {
            return
        }

        lastQuery = query
        errorMessage = nil
        locationChoices = []
        isShowingLocationResults = false
        isLoading = true

        let searchID = UUID()
        activeSearchID = searchID
        currentSearchTask?.cancel()
        currentSearchTask = Task { [weak self] in
            guard let self else { return }
            await self.performLocationSearch(query: query, searchID: searchID)
        }
    }

    /// Backward-compatible entry point used by search controls.
    func search() {
        searchLocations()
    }

    /// Selects a geocoding result and loads weather for its coordinates.
    func selectLocation(_ location: LocationResult) {
        isShowingLocationResults = false
        locationChoices = []
        loadWeather(for: location)
    }

    /// Loads weather directly from a saved location without calling geocoding.
    func loadSavedLocation(_ savedLocation: SavedLocation) {
        searchText = savedLocation.locationName
        lastQuery = savedLocation.locationName
        isShowingLocationResults = false
        locationChoices = []
        loadWeather(for: savedLocation.locationResult)
    }

    /// Loads current weather and the five-day forecast for a known coordinate-bearing location.
    func loadWeather(for location: LocationResult) {
        guard !isLoading else {
            return
        }

        errorMessage = nil
        selectedLocation = location
        updateFavoriteState()
        isLoading = true

        let searchID = UUID()
        activeSearchID = searchID
        currentSearchTask?.cancel()
        currentSearchTask = Task { [weak self] in
            guard let self else { return }
            await self.performWeatherLoad(location: location, searchID: searchID)
        }
    }

    /// Retries the selected location if available, otherwise repeats the most recent text search.
    func retry() {
        guard !isLoading else {
            return
        }

        if let selectedLocation {
            loadWeather(for: selectedLocation)
        } else if let lastQuery, !lastQuery.isEmpty {
            searchText = lastQuery
            searchLocations()
        }
    }

    func dismissLocationResults() {
        isShowingLocationResults = false
    }

    func cancelSearch() {
        currentSearchTask?.cancel()
        currentSearchTask = nil
        isLoading = false
        activeSearchID = nil
    }

    func toggleFavoriteForSelectedLocation() {
        guard let selectedLocation, let savedLocationStore else {
            errorMessage = APIError.persistenceFailure.errorDescription
            return
        }

        do {
            if try savedLocationStore.isSaved(location: selectedLocation) {
                try savedLocationStore.remove(location: selectedLocation)
            } else {
                try savedLocationStore.save(location: selectedLocation)
            }

            refreshSavedLocations()
            updateFavoriteState()
        } catch {
            errorMessage = APIError.persistenceFailure.errorDescription
        }
    }

    func deleteSavedLocation(_ savedLocation: SavedLocation) {
        guard let savedLocationStore else {
            errorMessage = APIError.persistenceFailure.errorDescription
            return
        }

        do {
            try savedLocationStore.delete(savedLocation)
            refreshSavedLocations()
            updateFavoriteState()
        } catch {
            errorMessage = APIError.persistenceFailure.errorDescription
        }
    }

    func refreshSavedLocations() {
        guard let savedLocationStore else {
            savedLocations = []
            return
        }

        do {
            savedLocations = try savedLocationStore.savedLocations()
        } catch {
            savedLocations = []
            errorMessage = APIError.persistenceFailure.errorDescription
        }
    }

    private func performLocationSearch(query: String, searchID: UUID) async {
        defer {
            finishLoading(searchID: searchID)
        }

        do {
            let locations = try await geocodingService.locations(for: query)
            try Task.checkCancellation()

            guard activeSearchID == searchID else {
                return
            }

            if locations.count == 1, let location = locations.first {
                selectedLocation = location
                updateFavoriteState()
                await performWeatherLoad(location: location, searchID: searchID)
            } else {
                locationChoices = locations
                isShowingLocationResults = true
                errorMessage = nil
            }
        } catch is CancellationError {
            if activeSearchID == searchID {
                errorMessage = nil
            }
        } catch {
            guard activeSearchID == searchID else {
                return
            }

            locationChoices = []
            isShowingLocationResults = false
            applyUserFacingError(error)
        }
    }

    private func performWeatherLoad(location: LocationResult, searchID: UUID) async {
        defer {
            finishLoading(searchID: searchID)
        }

        do {
            guard let latitude = location.latitude, let longitude = location.longitude else {
                throw APIError.invalidSelectedLocation
            }

            let report = try await weatherService.weather(latitude: latitude, longitude: longitude)
            try Task.checkCancellation()

            guard activeSearchID == searchID else {
                return
            }

            weatherSummary = try makeWeatherSummary(location: location, report: report)
            dailyForecasts = report.dailyForecasts
            selectedLocation = location
            errorMessage = nil
            updateFavoriteState()
        } catch is CancellationError {
            if activeSearchID == searchID {
                errorMessage = nil
            }
        } catch {
            guard activeSearchID == searchID else {
                return
            }

            applyUserFacingError(error)
        }
    }

    private func finishLoading(searchID: UUID) {
        if activeSearchID == searchID {
            isLoading = false
            currentSearchTask = nil
        }
    }

    private func makeWeatherSummary(location: LocationResult, report: WeatherReport) throws -> WeatherSummary {
        guard let latitude = location.latitude,
              let longitude = location.longitude,
              let temperature = report.current.temperature,
              let humidity = report.current.humidity,
              let weatherCode = report.current.weatherCode,
              let windSpeed = report.current.windSpeed else {
            throw APIError.invalidReturnedData
        }

        return WeatherSummary(
            locationStableKey: location.stableKey,
            locationName: location.name,
            regionDescription: location.coordinateDescription,
            latitude: latitude,
            longitude: longitude,
            temperature: temperature,
            humidity: humidity,
            windSpeed: windSpeed,
            condition: WeatherCondition.condition(for: weatherCode),
            isDay: report.current.isDay.map { $0 != 0 } ?? true
        )
    }

    private func updateFavoriteState() {
        guard let selectedLocation, let savedLocationStore else {
            isSelectedLocationSaved = false
            return
        }

        do {
            isSelectedLocationSaved = try savedLocationStore.isSaved(location: selectedLocation)
        } catch {
            isSelectedLocationSaved = false
        }
    }

    private func applyUserFacingError(_ error: Error) {
        if let localizedError = error as? LocalizedError, let message = localizedError.errorDescription {
            errorMessage = message
        } else {
            errorMessage = "Something went wrong. Try again."
        }
    }
}
