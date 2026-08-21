# WeatherApp - SkyCast

SkyCast is a SwiftUI weather app that searches Open-Meteo for locations, lets the user choose among ambiguous results, displays current conditions, shows a five-day forecast, and saves favorite locations. An internet connection is required for weather data. Open-Meteo does not require an API key.

## Features

- Location search using Open-Meteo Geocoding
- Multiple-location selection when a search returns more than one match
- Current temperature, humidity, wind speed, and condition
- Five-day forecast with high, low, condition, and precipitation probability
- Saved favorite locations with add, remove, list, delete, and direct-load behavior
- Retry support for previous searches or selected locations
- Blue-to-indigo SwiftUI design with Material cards
- Dynamic Type-friendly layout and VoiceOver labels

## Architecture

The app uses MVVM:

- `Models`: geocoding, weather, forecast, and saved-location models
- `Services`: API errors, geocoding, weather, and saved-location persistence
- `ViewModels`: `WeatherViewModel` coordinates search, selection, weather loading, retry, and favorite state
- `Views`: `ContentView`, location selection, saved locations, and forecast cards
- `Documentation`: implementation report

Networking, decoding, persistence, and workflow logic are kept out of SwiftUI views.

## APIs

Geocoding endpoint:

```text
https://geocoding-api.open-meteo.com/v1/search
```

Query fields:

```text
name=<trimmed search>
count=5
language=en
format=json
```

Forecast endpoint:

```text
https://api.open-meteo.com/v1/forecast
```

Query fields:

```text
latitude=<selected latitude>
longitude=<selected longitude>
current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max
temperature_unit=fahrenheit
wind_speed_unit=mph
timezone=auto
forecast_days=5
```

Requests are built with `URLComponents` and `URLQueryItem`, not URL string concatenation. Debug builds print final request URLs.

## Persistence

Saved locations use a focused `Codable` model persisted with `UserDefaults` through `SavedLocationStore`. SwiftData was evaluated because the deployment target supports it, but the command-line build environment could not load the SwiftData macro plugin, so the allowed Codable fallback was used to keep the project buildable and deterministic here.

Duplicate saved locations are prevented with a stable key based on the Open-Meteo location ID when available, or a deterministic fallback from name and coordinates.

## File Structure

```text
WeatherApp/
  Models/
    LocationModels.swift
    SavedLocation.swift
    WeatherModels.swift
  Services/
    APIError.swift
    GeocodingService.swift
    SavedLocationStore.swift
    WeatherService.swift
  ViewModels/
    WeatherViewModel.swift
  Views/
    ContentView.swift
    DailyForecastCard.swift
    LocationResultsView.swift
    SavedLocationsView.swift
  Documentation/
    Implementation Report.md
  WeatherAppApp.swift
README.md
```

## Setup and Run

1. Open `WeatherApp.xcodeproj` in Xcode.
2. Select the existing `WeatherApp` scheme.
3. Choose an iOS Simulator.
4. Build and run.
5. Search for a place such as `Springfield` to see multiple choices, or `Murfreesboro` for weather.

## Build Verification

Project list command:

```bash
xcodebuild -list -project WeatherApp.xcodeproj
```

Build command:

```bash
xcodebuild -project WeatherApp.xcodeproj -scheme WeatherApp -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/WeatherAppDerivedData CODE_SIGNING_ALLOWED=NO build
```

Result: `** BUILD SUCCEEDED **`.

The generated Swift compile list confirmed every app Swift file is included exactly once in the `WeatherApp` target.

## Screenshot Placeholders

### Location Search and Selection

_Add screenshot here._

### Current Weather and Five-Day Forecast

_Add screenshot here._

### Saved Locations

_Add screenshot here._

## Known Limitations

- Only up to five geocoding results are shown.
- Forecast is limited to five daily rows.
- Units are fixed to Fahrenheit and miles per hour.
- Saved locations are device-local.
- The app depends on Open-Meteo availability.
- Simulator launch and interactive UI checks were blocked in this environment by CoreSimulatorService connection failures.

## Future Improvements

- Mock-network unit tests for every workflow and error case
- Automatic retry with exponential backoff
- Offline detection
- Response caching
- Rate-limit handling
- More detailed diagnostics
- More saved-location sorting and editing options
- User-selectable units

## Assignment Checklist

| Requirement | Status |
| --- | --- |
| Current weather preserved | Complete |
| Five-day forecast added | Complete |
| Multiple-location search results added | Complete |
| Saved favorite locations added | Complete |
| No API key added | Complete |
| MVVM retained | Complete |
| URLSession and async/await used | Complete |
| Codable models used | Complete |
| URLComponents and URLQueryItem used | Complete |
| HTTP validation retained | Complete |
| Debug URL logging retained | Complete |
| Debug decoding snippets retained | Complete |
| Weather-code fallback retained | Complete |
| Favorite duplicates prevented | Complete |
| Saved locations skip geocoding | Complete |
| New Swift files compile in target | Verified |
| App scheme builds | Verified |
| Interactive simulator testing | Blocked by CoreSimulatorService |
