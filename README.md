# WeatherApp - SkyCast

SkyCast is a SwiftUI weather app that searches Open-Meteo for locations, lets the user choose among ambiguous results, displays current conditions and a five-day forecast, and saves favorite locations. The app now includes condition-aware animated weather scenes, day/night presentation, polished weather cards, and Reduce Motion support. An internet connection is required. Open-Meteo does not require an API key.

## Features

- Location search using Open-Meteo Geocoding
- Multiple-location selection when a search returns more than one match
- Current temperature, humidity, wind speed, condition, and day/night-aware imagery
- Five-day forecast with high, low, condition, and precipitation probability
- Saved favorite locations with add, remove, list, delete, and direct-load behavior
- Condition-aware animated backgrounds for clear, cloudy, fog, rain, snow, storm, and unknown states
- Canvas-based rain, snow, fog, cloud, and star effects
- Premium current-weather hero card, improved metric cards, and redesigned forecast cards
- Loading card with accessible progress and stable placeholder layout
- Favorite, retry, location-selection, and deletion haptics
- Dynamic Type, VoiceOver labels, Light Mode, Dark Mode, and Reduce Motion support

## Architecture

The app uses MVVM:

- `Models`: geocoding, weather, forecast, saved-location, and visual-style models
- `Services`: API errors, geocoding, weather, saved-location persistence, and haptic helper
- `ViewModels`: `WeatherViewModel` coordinates search, selection, weather loading, retry, cancellation, stale-response protection, and favorite state
- `Views`: `ContentView`, location selection, saved locations, forecast cards, and reusable visual components
- `Documentation`: implementation report

Networking, decoding, persistence, haptics, and workflow logic are kept out of the main SwiftUI screen.

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
current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day
daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max
temperature_unit=fahrenheit
wind_speed_unit=mph
timezone=auto
forecast_days=5
```

Requests are built with `URLComponents` and `URLQueryItem`, not URL string concatenation. Foundation handles encoding for query values, and debug builds print the final request URLs for troubleshooting.

## Modeling Choices

The app decodes only the fields it uses. Geocoding models keep identity, display names, coordinates, country, optional administrative region, timezone, and population. Weather models decode the current object, optional `is_day`, and daily forecast arrays. WMO weather codes map into one `WeatherCondition` model with a reusable condition kind, description, and SF Symbol. `WeatherVisualStyle` then derives presentation values from that condition and Open-Meteo's day/night flag without scattering weather-code checks through the views.

## Coordinate Workflow

A text search always starts with geocoding. If Open-Meteo returns one valid location, SkyCast automatically loads weather for those coordinates. If multiple valid locations are returned, the app presents a selection sheet and waits for the user to choose one before calling the Forecast API. Saved locations already contain coordinates, so they skip geocoding and load weather directly.

## Persistence

Saved locations use a focused `Codable` model persisted with `UserDefaults` through `SavedLocationStore`. This project uses the allowed Codable fallback rather than SwiftData so it remains compatible with the existing target configuration and simple classroom project structure. Duplicate saved locations are prevented with the Open-Meteo location ID when available, or a deterministic fallback based on name and coordinates.

## Visual System

`WeatherVisualStyle` centralizes background gradients, primary weather symbols, accent colors, glow colors, particle types, foreground colors, and lightning behavior. `AnimatedWeatherScene` renders the full-screen condition-aware background, while `WeatherParticleCanvas` uses `Canvas` and `TimelineView` for efficient particles. Reduce Motion disables continuous particle motion and lightning flashes while preserving static weather artwork.

## File Structure

```text
WeatherApp/
  Models/
    LocationModels.swift
    SavedLocation.swift
    WeatherModels.swift
    WeatherVisualStyle.swift
  Services/
    APIError.swift
    GeocodingService.swift
    SavedLocationStore.swift
    WeatherService.swift
  ViewModels/
    WeatherViewModel.swift
  Views/
    Components/
      AnimatedWeatherScene.swift
      HapticFeedback.swift
      WeatherHeroCard.swift
      WeatherLoadingView.swift
      WeatherMetricCard.swift
      WeatherParticleCanvas.swift
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
5. Search for `Springfield` to see multiple choices, or `Murfreesboro` for a direct weather lookup.
6. Use the heart button on the current-weather card to save or remove a favorite.

## Build Verification

Project list command:

```bash
xcodebuild -list -project WeatherApp.xcodeproj
```

Build command:

```bash
xcodebuild -project WeatherApp.xcodeproj -scheme WeatherApp -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/WeatherAppVisualDerivedData CODE_SIGNING_ALLOWED=NO build
```

Result: `** BUILD SUCCEEDED **`.

The generated Swift compile list confirmed every app Swift file, including the new visual components, is included exactly once in the `WeatherApp` target.

## Screenshot Placeholders

### Location Search and Selection

_Add screenshot here._

### Current Weather Hero and Five-Day Forecast

_Add screenshot here._

### Saved Locations

_Add screenshot here._

### Animated Weather Background

_Add screenshot here._

## Known Limitations

- Only up to five geocoding results are shown.
- Forecast is limited to five daily rows.
- Units are fixed to Fahrenheit and miles per hour.
- Saved locations are device-local.
- The app depends on Open-Meteo availability and an internet connection.
- Animated artwork uses native symbolic/vector effects rather than real radar imagery.
- Simulator launch and interactive UI checks were blocked in this Codex shell by CoreSimulatorService connection failures.

## Future Improvements

- Add mock-network unit tests for every workflow and error case
- Add automatic retry with exponential backoff
- Add offline detection and response caching
- Add rate-limit handling and richer diagnostics
- Add user-selectable units
- Add saved-location sorting and editing options
- Add sunrise/sunset-aware visual refinements
- Add more detailed weather scenes for wind, hail, and severe weather alerts

## Assignment Checklist

| Requirement | Status |
| --- | --- |
| Current weather preserved | Complete |
| Five-day forecast preserved | Complete |
| Multiple-location search preserved | Complete |
| Saved favorite locations preserved | Complete |
| No API key added | Complete |
| MVVM retained | Complete |
| URLSession and async/await used | Complete |
| Codable models used | Complete |
| URLComponents and URLQueryItem used | Complete |
| HTTP validation retained | Complete |
| Debug URL logging retained | Complete |
| Debug decoding snippets retained | Complete |
| `is_day` requested and decoded | Complete |
| Condition-aware visual style model added | Complete |
| Animated weather scene added | Complete |
| Canvas/TimelineView particle approach used | Complete |
| Reduce Motion support added | Complete |
| Hero weather card redesigned | Complete |
| Metric cards improved | Complete |
| Forecast cards improved | Complete |
| Favorite animation and haptics added | Complete |
| New Swift files compile in target | Verified |
| App scheme builds | Verified |
| Interactive simulator testing | Blocked by CoreSimulatorService |
