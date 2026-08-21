SkyCast Weather

SkyCast is a SwiftUI weather application that lets users search for a city or location and view its current conditions. The app first resolves the search into geographic coordinates with the Open-Meteo Geocoding API, then uses those coordinates to retrieve live weather data from the Open-Meteo Forecast API.






Features

Search by city or location name

Two-step geocoding and weather request workflow

Current temperature in Fahrenheit

Relative humidity

Wind speed in miles per hour

Human-readable weather conditions

WMO weather-code mapping with matching SF Symbols

Loading, empty, success, and error states

Retry support after failed requests

Protection against blank, duplicate, cancelled, and stale searches

Responsive interface supporting smaller devices, Dynamic Type, Light Mode, and Dark Mode

VoiceOver-friendly labels and values

Screenshots

Add the two required screenshots to an Images folder and update the filenames below.

Location Search

Current Weather

Images/location-search.png

Images/current-weather.png

<!-- After adding the screenshots, replace the table above with:
| Location Search | Current Weather |
| --- | --- |
| ![SkyCast location search](Images/location-search.png) | ![SkyCast current weather](Images/current-weather.png) |
-->

How It Works

The user enters a city or location.

WeatherViewModel trims and validates the search.

GeocodingService sends the location name to Open-Meteo Geocoding.

The service returns the first matching location's latitude and longitude.

WeatherService uses those coordinates to request current conditions.

The ViewModel converts the response into presentation-ready weather data.

SwiftUI displays the location, temperature, humidity, wind speed, weather condition, and corresponding symbol.

If geocoding returns no results, SkyCast stops the workflow and does not make an unnecessary forecast request.

Architecture

SkyCast follows the Model-View-ViewModel pattern and keeps networking outside the SwiftUI interface.

WeatherApp/
├── Models/
│   ├── LocationModels.swift
│   └── WeatherModels.swift
├── Services/
│   ├── APIError.swift
│   ├── GeocodingService.swift
│   └── WeatherService.swift
├── ViewModels/
│   └── WeatherViewModel.swift
├── Views/
│   └── ContentView.swift
├── Documentation/
│   └── Implementation Report.md
└── WeatherAppApp.swift

Models

The models use Codable and contain only the fields required by the interface. LocationModels.swift decodes the geocoding results, including the location name, coordinates, country, and optional administrative region. WeatherModels.swift decodes the forecast's current object and uses CodingKeys to map Open-Meteo's snake-case JSON keys to clear Swift property names.

Services

GeocodingService and WeatherService each handle one API responsibility. Both services build requests, perform URLSession calls, validate HTTP responses, and decode JSON. Protocol-based service abstractions allow mock implementations to be injected for testing.

ViewModel

WeatherViewModel coordinates the complete search workflow and manages the search text, loading state, weather result, user-facing error message, last query, retry behavior, task cancellation, and stale-result protection.

Views

The SwiftUI interface renders the ViewModel's empty, loading, success, and error states. The design uses a blue-to-indigo gradient, Material cards, rounded corners, semantic typography, SF Symbols, and accessibility metadata.

APIs

SkyCast uses the free Open-Meteo APIs. No API key is required.

Geocoding API

https://geocoding-api.open-meteo.com/v1/search

Query items:

name=<location>
count=1
language=en
format=json

Forecast API

https://api.open-meteo.com/v1/forecast

Query items:

latitude=<latitude>
longitude=<longitude>
current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
temperature_unit=fahrenheit
wind_speed_unit=mph
timezone=auto

URL Construction

Both services use URLComponents and URLQueryItem instead of manually concatenating query strings. This allows Foundation to encode location names and parameters correctly. If the components cannot produce a valid URL, the service throws an invalid-URL error before starting a network request. Debug builds print the final request URLs for troubleshooting.

Error Handling

SkyCast distinguishes between:

Invalid URL construction

Network or transport failures

Invalid HTTP responses

Unsuccessful HTTP status codes

Empty geocoding results

JSON decoding failures

Invalid or incomplete API data

Errors are converted into concise messages for the user. When a prior nonempty query exists, the error interface provides a Retry button. Debug builds print a short response snippet for decoding failures without exposing raw JSON in the UI.

Weather-Code Support

WMO weather codes are mapped to readable descriptions and SF Symbols for:

Clear and mainly clear skies

Partly cloudy and overcast conditions

Fog

Drizzle and freezing drizzle

Rain and freezing rain

Snow

Rain and snow showers

Thunderstorms

Unknown conditions

Unrecognized codes use a safe fallback condition and symbol instead of causing a failure.

Requirements

A recent version of Xcode

An iOS Simulator or physical iPhone supported by the project's deployment target

An active internet connection

Getting Started

Clone or download the repository.

Open WeatherApp.xcodeproj in Xcode.

Select the WeatherApp scheme.

Choose an iOS Simulator or connected iPhone.

Build and run with Command-R.

Enter a location such as Murfreesboro and select Search.

No secrets, API keys, or additional packages are required.

Assignment Requirements Covered

URLSession GET requests

Codable JSON decoding

Open-Meteo Geocoding API

Open-Meteo Forecast API

URLComponents and URLQueryItem

Temperature display

Humidity display

Wind-speed display

Weather-condition display

Network, URL, response, empty-result, and decoding error handling

API logic separated from SwiftUI views

Separate geocoding and weather services

ViewModel-managed loading, success, empty, and error states

Professional SwiftUI design

Accessibility support

Known Limitations

Only the first geocoding result is selected.

Users cannot choose among multiple locations with the same name.

The app displays current conditions rather than hourly or multi-day forecasts.

Units are fixed to Fahrenheit and miles per hour.

Weather data requires internet access and Open-Meteo availability.

Future Improvements

Add a location-selection screen for ambiguous searches

Add hourly and multi-day forecasts

Add user-selectable measurement units

Add offline detection and cached weather data

Retry temporary failures with exponential backoff

Add deterministic service and ViewModel tests with mocked network responses

Add saved and recently searched locations

Documentation

See WeatherApp/Documentation/Implementation Report.md for the complete technical implementation report and assignment-compliance details.

Acknowledgments

Weather data and geocoding are provided by Open-Meteo.
