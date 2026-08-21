//
//  WeatherLoadingView.swift
//  WeatherApp
//
//  Provides a stable professional loading state while location and weather requests run.
//

import SwiftUI

struct WeatherLoadingView: View {
    let style: WeatherVisualStyle

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(style.glowColor.opacity(0.22))
                    .frame(width: 88, height: 88)
                    .blur(radius: 10)

                ProgressView()
                    .controlSize(.large)
                    .tint(style.accentColor)
                    .accessibilityHidden(true)

                Image(systemName: style.primarySymbol)
                    .font(.system(size: 42, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(style.accentColor, .white.opacity(0.86))
                    .offset(y: -56)
                    .opacity(reduceMotion ? 0.85 : 1)
            }
            .frame(height: 112)

            VStack(spacing: 6) {
                Text("Loading weather")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Fetching matching locations and forecast data.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.74))
                    .multilineTextAlignment(.center)
            }

            skeletonRows
        }
        .frame(maxWidth: .infinity)
        .padding(24)
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
        .accessibilityLabel("Loading weather")
    }

    private var skeletonRows: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 5)
                .fill(.white.opacity(0.24))
                .frame(height: 18)
                .frame(maxWidth: 220)

            RoundedRectangle(cornerRadius: 5)
                .fill(.white.opacity(0.16))
                .frame(height: 14)
                .frame(maxWidth: 280)
        }
        .redacted(reason: .placeholder)
    }
}
