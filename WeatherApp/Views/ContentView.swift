//
//  ContentView.swift
//  WeatherApp
//
//  Presents the SkyCast search, current weather, forecast, and saved-location interface.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: WeatherViewModel
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isShowingSavedLocations = false

    @MainActor
    init(viewModel: WeatherViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? WeatherViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.72), Color.indigo.opacity(0.84)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        searchPanel
                        stateContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.isShowingLocationResults) {
            LocationResultsView(
                locations: viewModel.locationChoices,
                onSelect: viewModel.selectLocation,
                onCancel: viewModel.dismissLocationResults
            )
        }
        .sheet(isPresented: $isShowingSavedLocations, onDismiss: viewModel.refreshSavedLocations) {
            SavedLocationsView(
                savedLocations: viewModel.savedLocations,
                onSelect: { savedLocation in
                    isShowingSavedLocations = false
                    viewModel.loadSavedLocation(savedLocation)
                },
                onDelete: viewModel.deleteSavedLocation,
                onDismiss: {
                    isShowingSavedLocations = false
                }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 52, weight: .semibold))
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Text("SkyCast")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Current conditions and five-day outlook")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.86))
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("SkyCast, current conditions and five-day outlook")
    }

    private var searchPanel: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                TextField("Search city or location", text: $viewModel.searchText)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(false)
                    .submitLabel(.search)
                    .focused($isSearchFieldFocused)
                    .onSubmit(submitSearch)
                    .accessibilityLabel("Location search")
                    .accessibilityValue(viewModel.searchText.isEmpty ? "Empty" : viewModel.searchText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            HStack(spacing: 12) {
                Button(action: submitSearch) {
                    Label(viewModel.isLoading ? "Searching" : "Search", systemImage: "location.magnifyingglass")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .disabled(!viewModel.canSearch)
                .accessibilityHint("Searches Open-Meteo for matching locations")

                Button {
                    viewModel.refreshSavedLocations()
                    isShowingSavedLocations = true
                } label: {
                    Label("Saved", systemImage: "heart.text.square")
                        .font(.headline)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .accessibilityLabel("Saved locations")
                .accessibilityHint("Shows saved weather locations")
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var stateContent: some View {
        if viewModel.isLoading && viewModel.weatherSummary == nil {
            LoadingCard()
        } else if let weatherSummary = viewModel.weatherSummary {
            WeatherContent(
                summary: weatherSummary,
                dailyForecasts: viewModel.dailyForecasts,
                isLoading: viewModel.isLoading,
                isFavorite: viewModel.isSelectedLocationSaved,
                favoriteAction: viewModel.toggleFavoriteForSelectedLocation
            )

            if let errorMessage = viewModel.errorMessage {
                ErrorCard(message: errorMessage, canRetry: viewModel.canRetry, retryAction: viewModel.retry)
            }
        } else if let errorMessage = viewModel.errorMessage {
            ErrorCard(message: errorMessage, canRetry: viewModel.canRetry, retryAction: viewModel.retry)
        } else {
            EmptyWeatherState()
        }
    }

    private func submitSearch() {
        isSearchFieldFocused = false
        viewModel.searchLocations()
    }
}

private struct WeatherContent: View {
    let summary: WeatherSummary
    let dailyForecasts: [DailyForecast]
    let isLoading: Bool
    let isFavorite: Bool
    let favoriteAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            MainWeatherCard(summary: summary, isFavorite: isFavorite, favoriteAction: favoriteAction)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 14)], spacing: 14) {
                MetricCard(
                    title: "Humidity",
                    value: summary.humidityText,
                    symbolName: "humidity.fill",
                    accessibilityValue: "\(summary.humidity) percent"
                )
                MetricCard(
                    title: "Wind Speed",
                    value: summary.windSpeedText,
                    symbolName: "wind",
                    accessibilityValue: summary.windSpeedText
                )
            }

            if isLoading {
                RefreshingWeatherView()
            }

            if !dailyForecasts.isEmpty {
                ForecastSection(forecasts: dailyForecasts)
            }
        }
    }
}

private struct MainWeatherCard: View {
    let summary: WeatherSummary
    let isFavorite: Bool
    let favoriteAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Text(summary.locationName)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    if !summary.regionDescription.isEmpty {
                        Text(summary.regionDescription)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: favoriteAction) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3.weight(.semibold))
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(isFavorite ? "Remove \(summary.locationName) from saved locations" : "Save \(summary.locationName)")
                .accessibilityHint("Toggles this location in saved locations")
            }

            Image(systemName: summary.condition.symbolName)
                .font(.system(size: 76, weight: .semibold))
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text(summary.temperatureText)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(summary.condition.description)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Current weather for \(summary.locationName)")
        .accessibilityValue("\(summary.condition.description), \(summary.temperatureText), humidity \(summary.humidity) percent, wind \(summary.windSpeedText)")
    }
}

private struct ForecastSection: View {
    let forecasts: [DailyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                HStack(spacing: 14) {
                    ForEach(forecasts) { forecast in
                        DailyForecastCard(forecast: forecast)
                    }
                }
                .padding(.bottom, 4)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let symbolName: String
    let accessibilityValue: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbolName)
                .font(.title2.weight(.semibold))
                .symbolRenderingMode(.multicolor)
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilityValue)
    }
}

private struct RefreshingWeatherView: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
            Text("Refreshing weather")
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Refreshing weather")
    }
}

private struct LoadingCard: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
            Text("Loading weather")
                .font(.headline)
            Text("Fetching matching locations and current forecast data.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading weather")
    }
}

private struct EmptyWeatherState: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "map.fill")
                .font(.system(size: 46, weight: .semibold))
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Text("Search for a Location")
                .font(.title3.weight(.bold))

            Text("Enter a city, town, or place name to choose a location and see current conditions with a five-day forecast.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct ErrorCard: View {
    let message: String
    let canRetry: Bool
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42, weight: .semibold))
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Text("Unable to Load Weather")
                .font(.title3.weight(.bold))

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if canRetry {
                Button(action: retryAction) {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .accessibilityHint("Retries the previous weather request")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
