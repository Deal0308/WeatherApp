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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @MainActor
    init(viewModel: WeatherViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? WeatherViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedWeatherScene(style: visualStyle)
                    .id(visualStyle.id)
                    .transition(.opacity)

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
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: viewModel.isLoading)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: viewModel.errorMessage)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.isShowingLocationResults) {
            LocationResultsView(
                locations: viewModel.locationChoices,
                onSelect: { location in
                    HapticFeedback.selection()
                    isSearchFieldFocused = false
                    viewModel.selectLocation(location)
                },
                onCancel: viewModel.dismissLocationResults
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingSavedLocations, onDismiss: viewModel.refreshSavedLocations) {
            SavedLocationsView(
                savedLocations: viewModel.savedLocations,
                onSelect: { savedLocation in
                    HapticFeedback.selection()
                    isShowingSavedLocations = false
                    isSearchFieldFocused = false
                    viewModel.loadSavedLocation(savedLocation)
                },
                onDelete: { savedLocation in
                    HapticFeedback.selection()
                    viewModel.deleteSavedLocation(savedLocation)
                },
                onDismiss: {
                    isShowingSavedLocations = false
                }
            )
            .presentationDetents([.medium, .large])
        }
    }

    private var visualStyle: WeatherVisualStyle {
        guard let summary = viewModel.weatherSummary else {
            return .defaultDay
        }

        return WeatherVisualStyle.style(for: summary.condition, isDay: summary.isDay)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 52, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(visualStyle.accentColor, .white.opacity(0.85))
                .shadow(color: visualStyle.glowColor, radius: 14)
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
                .tint(visualStyle.accentColor)
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
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(visualStyle.cardTint)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        if viewModel.isLoading && viewModel.weatherSummary == nil {
            WeatherLoadingView(style: visualStyle)
                .transition(contentTransition)
        } else if let weatherSummary = viewModel.weatherSummary {
            WeatherContent(
                summary: weatherSummary,
                dailyForecasts: viewModel.dailyForecasts,
                isLoading: viewModel.isLoading,
                isFavorite: viewModel.isSelectedLocationSaved,
                favoriteAction: viewModel.toggleFavoriteForSelectedLocation,
                style: visualStyle
            )
            .transition(contentTransition)

            if let errorMessage = viewModel.errorMessage {
                ErrorCard(message: errorMessage, canRetry: viewModel.canRetry, style: visualStyle, retryAction: retryWithFeedback)
                    .transition(contentTransition)
            }
        } else if let errorMessage = viewModel.errorMessage {
            ErrorCard(message: errorMessage, canRetry: viewModel.canRetry, style: visualStyle, retryAction: retryWithFeedback)
                .transition(contentTransition)
        } else {
            EmptyWeatherState(style: visualStyle)
                .transition(contentTransition)
        }
    }

    private var contentTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom))
    }

    private func submitSearch() {
        isSearchFieldFocused = false
        viewModel.searchLocations()
    }

    private func retryWithFeedback() {
        HapticFeedback.selection()
        viewModel.retry()
    }
}

private struct WeatherContent: View {
    let summary: WeatherSummary
    let dailyForecasts: [DailyForecast]
    let isLoading: Bool
    let isFavorite: Bool
    let favoriteAction: () -> Void
    let style: WeatherVisualStyle

    var body: some View {
        VStack(spacing: 18) {
            WeatherHeroCard(summary: summary, style: style, isFavorite: isFavorite, favoriteAction: favoriteAction)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 14)], spacing: 14) {
                WeatherMetricCard(
                    title: "Humidity",
                    value: summary.humidityText,
                    symbolName: "humidity.fill",
                    accessibilityValue: "\(summary.humidity) percent",
                    style: style
                )
                WeatherMetricCard(
                    title: "Wind Speed",
                    value: summary.windSpeedText,
                    symbolName: "wind",
                    accessibilityValue: summary.windSpeedText,
                    style: style
                )
            }

            if isLoading {
                RefreshingWeatherView(style: style)
            }

            if !dailyForecasts.isEmpty {
                ForecastSection(forecasts: dailyForecasts, style: style)
            }
        }
    }
}

private struct ForecastSection: View {
    let forecasts: [DailyForecast]
    let style: WeatherVisualStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                HStack(spacing: 14) {
                    ForEach(Array(forecasts.enumerated()), id: \.element.id) { index, forecast in
                        DailyForecastCard(forecast: forecast, style: style, index: index)
                    }
                }
                .padding(.bottom, 4)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RefreshingWeatherView: View {
    let style: WeatherVisualStyle

    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(style.accentColor)
            Text("Refreshing weather")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(style.cardTint)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Refreshing weather")
    }
}

private struct EmptyWeatherState: View {
    let style: WeatherVisualStyle

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "map.fill")
                .font(.system(size: 46, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(style.accentColor, .white.opacity(0.85))
                .accessibilityHidden(true)

            Text("Search for a Location")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text("Enter a city, town, or place name to choose a location and see current conditions with a five-day forecast.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.74))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(style.cardTint)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ErrorCard: View {
    let message: String
    let canRetry: Bool
    let style: WeatherVisualStyle
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42, weight: .semibold))
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Text("Unable to Load Weather")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(message)
                .font(.body)
                .foregroundStyle(.white.opacity(0.76))
                .multilineTextAlignment(.center)

            if canRetry {
                Button(action: retryAction) {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(style.accentColor)
                .accessibilityHint("Retries the previous weather request")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(style.cardTint)
        }
        .accessibilityElement(children: .contain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
