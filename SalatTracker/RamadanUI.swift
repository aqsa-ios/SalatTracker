//
//  RamadanUI.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

// MARK: - Theme

enum RamadanTheme {
    static let bgTop = Color(red: 0.06, green: 0.08, blue: 0.14)
    static let bgBottom = Color(red: 0.04, green: 0.06, blue: 0.11)

    static let glassFill = Color.white.opacity(0.10)
    static let glassStroke = Color.white.opacity(0.18)

    static let softGlow = Color(red: 0.95, green: 0.85, blue: 0.55).opacity(0.20)
    static let gold = Color(red: 0.95, green: 0.85, blue: 0.55)

    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.70)
    static let textTertiary = Color.white.opacity(0.52)

    static let green = Color(red: 0.35, green: 0.85, blue: 0.55)
    static let red = Color(red: 0.95, green: 0.45, blue: 0.55)
    static let blue = Color(red: 0.45, green: 0.70, blue: 0.95)
}

// MARK: - Background

struct RamadanBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [RamadanTheme.bgTop, RamadanTheme.bgBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            StarsLayer()
                .opacity(0.45)
                .blendMode(.screen)

            SubtlePattern()
                .opacity(0.18)
                .blendMode(.overlay)

            // soft vignette
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.55)],
                center: .center,
                startRadius: 80,
                endRadius: 520
            )
            .ignoresSafeArea()

            // bottom glow
            RadialGradient(
                colors: [RamadanTheme.softGlow, Color.clear],
                center: .bottom,
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }
}

private struct StarsLayer: View {
    var body: some View {
        Canvas { context, size in
            let starCount = 140
            for i in 0..<starCount {
                let x = (Double(i * 73 % 997) / 997.0) * size.width
                let y = (Double(i * 191 % 1009) / 1009.0) * size.height
                let r = CGFloat((i % 5) + 1) * 0.7
                let rect = CGRect(x: x, y: y, width: r, height: r)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.75)))
            }
        }
    }
}

private struct SubtlePattern: View {
    var body: some View {
        Canvas { context, size in
            // faint geometric dots grid
            let step: CGFloat = 26
            var y: CGFloat = 0
            while y <= size.height {
                var x: CGFloat = 0
                while x <= size.width {
                    let rect = CGRect(x: x, y: y, width: 2.2, height: 2.2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.35)))
                    x += step
                }
                y += step
            }
        }
        .blur(radius: 0.6)
    }
}

// MARK: - Glass Components

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(RamadanTheme.glassFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(RamadanTheme.glassStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)
    }
}

struct GlassPill: View {
    let text: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(RamadanTheme.textPrimary)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

struct StatusBadge: View {
    enum Style { case prayed, missed, neutral }

    let text: String
    let style: Style

    private var tint: Color {
        switch style {
        case .prayed: return RamadanTheme.green
        case .missed: return RamadanTheme.red
        case .neutral: return RamadanTheme.blue
        }
    }

    private var icon: String {
        switch style {
        case .prayed: return "checkmark"
        case .missed: return "xmark"
        case .neutral: return "sparkle"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white.opacity(0.92))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .fill(tint.opacity(0.22))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }
}

struct GoldRing: View {
    var progress: Double // 0...1

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 10)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    RamadanTheme.gold,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: RamadanTheme.gold.opacity(0.25), radius: 10, x: 0, y: 0)
        }
        .animation(.easeInOut(duration: 0.25), value: progress)
    }
}

// MARK: - Helpers

extension View {
    func ramadanTitle() -> some View {
        self
            .font(.title2.weight(.semibold))
            .foregroundStyle(RamadanTheme.textPrimary)
    }

    func ramadanSubtitle() -> some View {
        self
            .font(.subheadline)
            .foregroundStyle(RamadanTheme.textSecondary)
    }
}
