//
//  WeatherMetricCard.swift
//  WeatherApp
//
//  Shows a single current-weather metric using the active condition accent color.
//

import SwiftUI

struct WeatherMetricCard: View {
    let title: String
    let value: String
    let symbolName: String
    let accessibilityValue: String
    let style: WeatherVisualStyle

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbolName)
                .font(.title2.weight(.semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(style.accentColor)
                .frame(width: 40, height: 40)
                .background(style.accentColor.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(style.cardTint)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilityValue)
    }
}
