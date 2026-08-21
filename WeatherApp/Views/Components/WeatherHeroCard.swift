//
//  WeatherHeroCard.swift
//  WeatherApp
//
//  Displays the premium current-weather hero with favorite controls and condition-aware artwork.
//

import SwiftUI

struct WeatherHeroCard: View {
    let summary: WeatherSummary
    let style: WeatherVisualStyle
    let isFavorite: Bool
    let favoriteAction: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var heartScale = 1.0

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(summary.locationName)
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)

                    if !summary.regionDescription.isEmpty {
                        Text(summary.regionDescription)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.78))
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                favoriteButton
            }

            HStack(alignment: .center, spacing: 18) {
                Image(systemName: style.primarySymbol)
                    .font(.system(size: 96, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(style.accentColor, .white.opacity(0.88), style.glowColor)
                    .shadow(color: style.glowColor, radius: 22)
                    .scaleEffect(reduceMotion ? 1 : 1.02)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    Text(summary.temperatureText)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .contentTransition(.numericText())

                    Text(summary.condition.description)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .overlay(.white.opacity(0.22))

            HStack(spacing: 12) {
                quickMetric(symbolName: "humidity.fill", label: "Humidity", value: summary.humidityText)
                quickMetric(symbolName: "wind", label: "Wind", value: summary.windSpeedText)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(style.cardTint)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: style.glowColor.opacity(0.24), radius: 24, x: 0, y: 12)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Current weather for \(summary.locationName)")
        .accessibilityValue("\(summary.condition.description), \(summary.temperatureText), humidity \(summary.humidity) percent, wind \(summary.windSpeedText)")
    }

    private var favoriteButton: some View {
        Button {
            if isFavorite {
                HapticFeedback.selection()
            } else {
                HapticFeedback.success()
            }

            favoriteAction()

            guard !reduceMotion else { return }
            heartScale = 1.18
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                heartScale = 1.0
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3.weight(.bold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(isFavorite ? .pink : .white, .white.opacity(0.82))
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.14), in: Circle())
                .scaleEffect(heartScale)
                .animation(reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.64), value: heartScale)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isFavorite)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove \(summary.locationName) from saved locations" : "Save \(summary.locationName)")
        .accessibilityValue(isFavorite ? "Saved" : "Not saved")
        .accessibilityHint("Toggles this location in saved locations")
    }

    private func quickMetric(symbolName: String, label: String, value: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.68))
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        } icon: {
            Image(systemName: symbolName)
                .font(.headline.weight(.semibold))
                .foregroundStyle(style.accentColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}
