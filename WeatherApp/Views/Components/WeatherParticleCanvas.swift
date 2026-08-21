//
//  WeatherParticleCanvas.swift
//  WeatherApp
//
//  Draws lightweight weather particles with Canvas so animated scenes stay efficient.
//

import SwiftUI

struct WeatherParticleCanvas: View {
    let type: WeatherParticleType
    let reduceMotion: Bool
    let isActive: Bool

    var body: some View {
        if reduceMotion || !isActive {
            ParticleCanvas(type: type, time: 0)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                ParticleCanvas(type: type, time: timeline.date.timeIntervalSinceReferenceDate)
            }
        }
    }
}

private struct ParticleCanvas: View {
    let type: WeatherParticleType
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            switch type {
            case .none:
                break
            case .stars:
                drawStars(in: context, size: size)
            case .clouds:
                drawClouds(in: context, size: size)
            case .fog:
                drawFog(in: context, size: size)
            case .drizzle:
                drawRain(in: context, size: size, count: 34, speed: 22, opacity: 0.28, length: 15)
            case .rain:
                drawRain(in: context, size: size, count: 58, speed: 48, opacity: 0.34, length: 22)
            case .heavyRain:
                drawRain(in: context, size: size, count: 86, speed: 68, opacity: 0.42, length: 25)
            case .snow:
                drawSnow(in: context, size: size)
            case .storm:
                drawRain(in: context, size: size, count: 72, speed: 62, opacity: 0.35, length: 24)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawRain(in context: GraphicsContext, size: CGSize, count: Int, speed: Double, opacity: Double, length: CGFloat) {
        guard size.width > 0, size.height > 0 else { return }

        for index in 0..<count {
            let seed = Double(index)
            let startX = normalized(seed * 17.31) * Double(size.width + 120) - 60
            let offsetY = (time * speed + seed * 41).truncatingRemainder(dividingBy: Double(size.height + 80))
            let x = CGFloat(startX)
            let y = CGFloat(offsetY) - 40
            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x - 12, y: y + length))
            context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: 1.4)
        }
    }

    private func drawSnow(in context: GraphicsContext, size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        for index in 0..<42 {
            let seed = Double(index)
            let diameter = CGFloat(2.4 + normalized(seed * 8.9) * 5.0)
            let baseX = normalized(seed * 29.1) * Double(size.width)
            let drift = sin(time * (0.22 + normalized(seed) * 0.28) + seed) * 18
            let y = (time * (10 + normalized(seed * 3.2) * 22) + seed * 37).truncatingRemainder(dividingBy: Double(size.height + 40)) - 20
            let rect = CGRect(x: CGFloat(baseX + drift), y: CGFloat(y), width: diameter, height: diameter)
            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.32 + normalized(seed * 11.0) * 0.38)))
        }
    }

    private func drawStars(in context: GraphicsContext, size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        for index in 0..<46 {
            let seed = Double(index)
            let x = CGFloat(normalized(seed * 21.7) * Double(size.width))
            let y = CGFloat(normalized(seed * 12.4) * Double(size.height * 0.78))
            let radius = CGFloat(1.2 + normalized(seed * 4.6) * 1.9)
            let pulse = 0.45 + 0.32 * sin(time * (0.4 + normalized(seed) * 0.8) + seed)
            let rect = CGRect(x: x, y: y, width: radius, height: radius)
            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(pulse)))
        }
    }

    private func drawClouds(in context: GraphicsContext, size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        for index in 0..<4 {
            let seed = Double(index)
            let width = size.width * CGFloat(0.42 + normalized(seed * 5.1) * 0.20)
            let height = width * 0.34
            let travel = size.width + width
            let speed = 7.0 + seed * 2.5
            let x = CGFloat((time * speed + seed * 180).truncatingRemainder(dividingBy: Double(travel))) - width
            let y = size.height * CGFloat(0.10 + normalized(seed * 7.8) * 0.34)
            let opacity = 0.10 + normalized(seed * 2.6) * 0.10
            let path = cloudPath(origin: CGPoint(x: x, y: y), width: width, height: height)
            context.fill(path, with: .color(.white.opacity(opacity)))
        }
    }

    private func drawFog(in context: GraphicsContext, size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        for index in 0..<5 {
            let seed = Double(index)
            let y = size.height * CGFloat(0.20 + normalized(seed * 6.0) * 0.55)
            let offset = CGFloat(sin(time * (0.10 + seed * 0.025) + seed) * 34)
            var path = Path()
            path.move(to: CGPoint(x: -80 + offset, y: y))
            path.addCurve(
                to: CGPoint(x: size.width + 80 + offset, y: y + 18),
                control1: CGPoint(x: size.width * 0.25, y: y - 34),
                control2: CGPoint(x: size.width * 0.70, y: y + 42)
            )
            context.stroke(path, with: .color(.white.opacity(0.12)), lineWidth: 30)
        }
    }

    private func cloudPath(origin: CGPoint, width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: origin.x, y: origin.y + height * 0.34, width: width * 0.46, height: height * 0.54))
        path.addEllipse(in: CGRect(x: origin.x + width * 0.22, y: origin.y, width: width * 0.44, height: height * 0.82))
        path.addEllipse(in: CGRect(x: origin.x + width * 0.50, y: origin.y + height * 0.28, width: width * 0.42, height: height * 0.58))
        return path
    }

    private func normalized(_ value: Double) -> Double {
        abs(sin(value * 12.9898) * 43758.5453).truncatingRemainder(dividingBy: 1)
    }
}
