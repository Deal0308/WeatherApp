//
//  WeatherVisualStyle.swift
//  WeatherApp
//
//  Centralizes condition-aware colors, symbols, particles, and motion settings for SkyCast views.
//

import SwiftUI

/// Lightweight scene effects used by the animated weather background.
enum WeatherParticleType {
    case none
    case stars
    case clouds
    case fog
    case drizzle
    case rain
    case heavyRain
    case snow
    case storm
}

/// Presentation style derived from the current weather condition and Open-Meteo day/night value.
struct WeatherVisualStyle {
    let id: String
    let backgroundColors: [Color]
    let primarySymbol: String
    let accentColor: Color
    let glowColor: Color
    let particleType: WeatherParticleType
    let foregroundColor: Color
    let secondaryForegroundColor: Color
    let cardTint: Color
    let allowsLightning: Bool

    static var defaultDay: WeatherVisualStyle {
        WeatherVisualStyle(
            id: "default-day",
            backgroundColors: [Color(red: 0.20, green: 0.55, blue: 0.92), Color(red: 0.17, green: 0.23, blue: 0.70)],
            primarySymbol: "cloud.sun.fill",
            accentColor: .cyan,
            glowColor: .cyan.opacity(0.45),
            particleType: .clouds,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.82),
            cardTint: .white.opacity(0.16),
            allowsLightning: false
        )
    }

    static func style(for condition: WeatherCondition, isDay: Bool) -> WeatherVisualStyle {
        switch condition.kind {
        case .clear, .mainlyClear:
            return isDay ? clearDay(symbol: condition.symbolName) : clearNight()
        case .partlyCloudy:
            return isDay ? partlyCloudyDay() : partlyCloudyNight()
        case .overcast:
            return WeatherVisualStyle(
                id: "overcast",
                backgroundColors: [Color(red: 0.36, green: 0.48, blue: 0.62), Color(red: 0.16, green: 0.22, blue: 0.34)],
                primarySymbol: "cloud.fill",
                accentColor: Color(red: 0.74, green: 0.84, blue: 0.94),
                glowColor: Color.white.opacity(0.25),
                particleType: .clouds,
                foregroundColor: .white,
                secondaryForegroundColor: .white.opacity(0.80),
                cardTint: .white.opacity(0.14),
                allowsLightning: false
            )
        case .fog:
            return WeatherVisualStyle(
                id: "fog",
                backgroundColors: [Color(red: 0.54, green: 0.63, blue: 0.70), Color(red: 0.28, green: 0.34, blue: 0.44)],
                primarySymbol: "cloud.fog.fill",
                accentColor: Color(red: 0.82, green: 0.90, blue: 0.94),
                glowColor: Color.white.opacity(0.28),
                particleType: .fog,
                foregroundColor: .white,
                secondaryForegroundColor: .white.opacity(0.82),
                cardTint: .white.opacity(0.16),
                allowsLightning: false
            )
        case .drizzle, .freezingDrizzle:
            return rainStyle(id: "drizzle", symbol: condition.symbolName, particleType: .drizzle, accent: Color(red: 0.58, green: 0.80, blue: 1.0))
        case .rain, .freezingRain:
            return rainStyle(id: "rain", symbol: condition.symbolName, particleType: .rain, accent: Color(red: 0.47, green: 0.73, blue: 1.0))
        case .rainShowers:
            return rainStyle(id: "heavy-rain", symbol: condition.symbolName, particleType: .heavyRain, accent: Color(red: 0.43, green: 0.68, blue: 0.98))
        case .snow:
            return snowStyle(id: "snow", symbol: "snowflake")
        case .snowShowers:
            return snowStyle(id: "snow-showers", symbol: condition.symbolName)
        case .thunderstorms:
            return WeatherVisualStyle(
                id: "thunderstorms",
                backgroundColors: [Color(red: 0.12, green: 0.16, blue: 0.26), Color(red: 0.03, green: 0.05, blue: 0.13)],
                primarySymbol: "cloud.bolt.rain.fill",
                accentColor: Color(red: 1.0, green: 0.84, blue: 0.28),
                glowColor: Color.yellow.opacity(0.46),
                particleType: .storm,
                foregroundColor: .white,
                secondaryForegroundColor: .white.opacity(0.78),
                cardTint: Color(red: 0.78, green: 0.84, blue: 1.0).opacity(0.13),
                allowsLightning: true
            )
        case .unknown:
            return WeatherVisualStyle(
                id: "unknown",
                backgroundColors: [Color(red: 0.28, green: 0.42, blue: 0.66), Color(red: 0.16, green: 0.18, blue: 0.34)],
                primarySymbol: "questionmark.circle.fill",
                accentColor: .cyan,
                glowColor: .cyan.opacity(0.30),
                particleType: .none,
                foregroundColor: .white,
                secondaryForegroundColor: .white.opacity(0.80),
                cardTint: .white.opacity(0.14),
                allowsLightning: false
            )
        }
    }

    private static func clearDay(symbol: String) -> WeatherVisualStyle {
        WeatherVisualStyle(
            id: "clear-day",
            backgroundColors: [Color(red: 0.18, green: 0.62, blue: 0.97), Color(red: 0.12, green: 0.30, blue: 0.82)],
            primarySymbol: symbol,
            accentColor: Color(red: 1.0, green: 0.78, blue: 0.28),
            glowColor: Color.yellow.opacity(0.55),
            particleType: .none,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.84),
            cardTint: .white.opacity(0.17),
            allowsLightning: false
        )
    }

    private static func clearNight() -> WeatherVisualStyle {
        WeatherVisualStyle(
            id: "clear-night",
            backgroundColors: [Color(red: 0.06, green: 0.09, blue: 0.24), Color(red: 0.13, green: 0.12, blue: 0.42)],
            primarySymbol: "moon.stars.fill",
            accentColor: Color(red: 0.78, green: 0.88, blue: 1.0),
            glowColor: Color.blue.opacity(0.50),
            particleType: .stars,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.80),
            cardTint: Color(red: 0.76, green: 0.82, blue: 1.0).opacity(0.14),
            allowsLightning: false
        )
    }

    private static func partlyCloudyDay() -> WeatherVisualStyle {
        WeatherVisualStyle(
            id: "partly-cloudy-day",
            backgroundColors: [Color(red: 0.28, green: 0.58, blue: 0.90), Color(red: 0.17, green: 0.24, blue: 0.64)],
            primarySymbol: "cloud.sun.fill",
            accentColor: Color(red: 1.0, green: 0.82, blue: 0.36),
            glowColor: Color.yellow.opacity(0.42),
            particleType: .clouds,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.82),
            cardTint: .white.opacity(0.16),
            allowsLightning: false
        )
    }

    private static func partlyCloudyNight() -> WeatherVisualStyle {
        WeatherVisualStyle(
            id: "partly-cloudy-night",
            backgroundColors: [Color(red: 0.08, green: 0.12, blue: 0.31), Color(red: 0.15, green: 0.17, blue: 0.43)],
            primarySymbol: "cloud.moon.fill",
            accentColor: Color(red: 0.78, green: 0.87, blue: 1.0),
            glowColor: Color.indigo.opacity(0.46),
            particleType: .clouds,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.80),
            cardTint: Color(red: 0.74, green: 0.80, blue: 1.0).opacity(0.13),
            allowsLightning: false
        )
    }

    private static func rainStyle(id: String, symbol: String, particleType: WeatherParticleType, accent: Color) -> WeatherVisualStyle {
        WeatherVisualStyle(
            id: id,
            backgroundColors: [Color(red: 0.22, green: 0.33, blue: 0.50), Color(red: 0.08, green: 0.12, blue: 0.24)],
            primarySymbol: symbol,
            accentColor: accent,
            glowColor: accent.opacity(0.36),
            particleType: particleType,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.80),
            cardTint: Color(red: 0.78, green: 0.88, blue: 1.0).opacity(0.14),
            allowsLightning: false
        )
    }

    private static func snowStyle(id: String, symbol: String) -> WeatherVisualStyle {
        WeatherVisualStyle(
            id: id,
            backgroundColors: [Color(red: 0.50, green: 0.64, blue: 0.82), Color(red: 0.20, green: 0.32, blue: 0.52)],
            primarySymbol: symbol,
            accentColor: Color(red: 0.86, green: 0.96, blue: 1.0),
            glowColor: Color.white.opacity(0.42),
            particleType: .snow,
            foregroundColor: .white,
            secondaryForegroundColor: .white.opacity(0.84),
            cardTint: .white.opacity(0.18),
            allowsLightning: false
        )
    }
}
