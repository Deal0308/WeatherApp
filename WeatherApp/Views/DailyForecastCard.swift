//
//  DailyForecastCard.swift
//  WeatherApp
//
//  Displays one day of the five-day forecast in a compact horizontal card.
//

import SwiftUI

struct DailyForecastCard: View {
    let forecast: DailyForecast
    let style: WeatherVisualStyle
    let index: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(forecast.dayText)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, forecast.dayText == "Today" ? 10 : 0)
                    .padding(.vertical, forecast.dayText == "Today" ? 4 : 0)
                    .background {
                        if forecast.dayText == "Today" {
                            Capsule().fill(style.accentColor.opacity(0.24))
                        }
                    }

                Text(forecast.dateText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.68))
            }

            Image(systemName: forecast.condition.symbolName)
                .font(.system(size: 44, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(color(for: forecast.condition), .white.opacity(0.82), style.glowColor)
                .frame(height: 50)
                .shadow(color: color(for: forecast.condition).opacity(0.30), radius: 10)
                .accessibilityHidden(true)

            Text(forecast.condition.description)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            VStack(spacing: 4) {
                Text(forecast.highTemperatureText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(forecast.lowTemperatureText)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
                Label(forecast.precipitationText, systemImage: "drop.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.cyan.opacity(0.90))
            }
        }
        .padding(16)
        .frame(width: 158)
        .frame(minHeight: 212)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(style.cardTint)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                )
        }
        .opacity(hasAppeared || reduceMotion ? 1 : 0)
        .offset(y: hasAppeared || reduceMotion ? 0 : 12)
        .task(id: forecast.id) {
            guard !reduceMotion else {
                hasAppeared = true
                return
            }

            hasAppeared = false
            try? await Task.sleep(nanoseconds: UInt64(index) * 55_000_000)
            withAnimation(.easeOut(duration: 0.28)) {
                hasAppeared = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(forecast.accessibilityDescription)
    }

    private func color(for condition: WeatherCondition) -> Color {
        switch condition.kind {
        case .clear, .mainlyClear:
            return .yellow
        case .partlyCloudy, .overcast, .fog:
            return .white
        case .drizzle, .freezingDrizzle, .rain, .freezingRain, .rainShowers:
            return .cyan
        case .snow, .snowShowers:
            return Color(red: 0.86, green: 0.96, blue: 1.0)
        case .thunderstorms:
            return .yellow
        case .unknown:
            return style.accentColor
        }
    }
}

struct DailyForecastCard_Previews: PreviewProvider {
    static var previews: some View {
        DailyForecastCard(
            forecast: DailyForecast(
                id: "2026-08-20",
                date: Date(),
                weatherCode: 2,
                condition: WeatherCondition.condition(for: 2),
                maximumTemperature: 78,
                minimumTemperature: 61,
                maximumPrecipitationProbability: 20
            ),
            style: .defaultDay,
            index: 0
        )
        .padding()
        .background(Color.indigo)
    }
}
