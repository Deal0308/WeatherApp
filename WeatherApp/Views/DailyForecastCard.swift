//
//  DailyForecastCard.swift
//  WeatherApp
//
//  Displays one day of the five-day forecast in a compact horizontal card.
//

import SwiftUI

struct DailyForecastCard: View {
    let forecast: DailyForecast

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 2) {
                Text(forecast.dayText)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(forecast.dateText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Image(systemName: forecast.condition.symbolName)
                .font(.system(size: 34, weight: .semibold))
                .symbolRenderingMode(.multicolor)
                .frame(height: 38)
                .accessibilityHidden(true)

            Text(forecast.condition.description)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            VStack(spacing: 4) {
                Text(forecast.highTemperatureText)
                    .font(.subheadline.weight(.bold))
                Text(forecast.lowTemperatureText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label(forecast.precipitationText, systemImage: "drop.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 148)
        .frame(minHeight: 190)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(forecast.accessibilityDescription)
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
            )
        )
        .padding()
        .background(Color.indigo)
    }
}
