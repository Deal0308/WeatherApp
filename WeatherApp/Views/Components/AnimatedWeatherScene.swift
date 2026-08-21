//
//  AnimatedWeatherScene.swift
//  WeatherApp
//
//  Renders the condition-aware background artwork behind the weather interface.
//

import SwiftUI

struct AnimatedWeatherScene: View {
    let style: WeatherVisualStyle

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LinearGradient(
                colors: style.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            atmosphericGlow
            heroAtmosphere

            WeatherParticleCanvas(
                type: style.particleType,
                reduceMotion: reduceMotion,
                isActive: scenePhase == .active
            )

            if style.allowsLightning && !reduceMotion && scenePhase == .active {
                lightningLayer
            }

            LinearGradient(
                colors: [.black.opacity(0.08), .black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: style.id)
        .accessibilityHidden(true)
    }

    private var atmosphericGlow: some View {
        RadialGradient(
            colors: [style.glowColor.opacity(0.44), .clear],
            center: .topTrailing,
            startRadius: 12,
            endRadius: 360
        )
        .blendMode(.screen)
    }

    @ViewBuilder
    private var heroAtmosphere: some View {
        switch style.particleType {
        case .stars:
            moon
        case .none:
            sun
        case .clouds:
            driftingSymbol(symbolName: "cloud.fill", size: 118, x: -120, y: -210, delay: 0)
            driftingSymbol(symbolName: "cloud.fill", size: 82, x: 118, y: -110, delay: 1.4)
        case .fog:
            driftingSymbol(symbolName: "cloud.fog.fill", size: 138, x: 100, y: -190, delay: 0.5)
        case .drizzle, .rain, .heavyRain:
            driftingSymbol(symbolName: "cloud.rain.fill", size: 124, x: 120, y: -205, delay: 0)
        case .snow:
            driftingSymbol(symbolName: "cloud.snow.fill", size: 126, x: 110, y: -205, delay: 0)
        case .storm:
            driftingSymbol(symbolName: "cloud.bolt.rain.fill", size: 132, x: 112, y: -205, delay: 0)
        }
    }

    private var sun: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Image(systemName: "sun.max.fill")
                .font(.system(size: 148, weight: .light))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow.opacity(0.82), .orange.opacity(0.32))
                .shadow(color: .yellow.opacity(0.42), radius: 34)
                .scaleEffect(1.0 + 0.025 * sin(time * 0.55))
                .rotationEffect(.degrees(reduceMotion ? 0 : time * 1.5))
                .offset(x: 135, y: -245)
                .opacity(0.70)
        }
    }

    private var moon: some View {
        Image(systemName: "moon.stars.fill")
            .font(.system(size: 128, weight: .light))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white.opacity(0.88), Color.cyan.opacity(0.55))
            .shadow(color: Color.cyan.opacity(0.34), radius: 28)
            .offset(x: 132, y: -238)
            .opacity(0.82)
    }

    private func driftingSymbol(symbolName: String, size: CGFloat, x: CGFloat, y: CGFloat, delay: Double) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate + delay
            Image(systemName: symbolName)
                .font(.system(size: size, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.22))
                .shadow(color: .black.opacity(0.10), radius: 12)
                .offset(x: x + CGFloat(sin(time * 0.14) * 18), y: y + CGFloat(cos(time * 0.11) * 8))
        }
    }

    private var lightningLayer: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 7.5)
            Color.white
                .opacity(phase > 0.08 && phase < 0.22 ? 0.18 : 0)
                .blendMode(.screen)
        }
    }
}
