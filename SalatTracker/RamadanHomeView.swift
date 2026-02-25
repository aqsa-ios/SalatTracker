//
//  RamadanHomeView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct RamadanHomeView: View {
    @EnvironmentObject private var store: AppStore

    // UI-only state for the “In Mosque / At Home” and Sunnah toggle per prayer
    @State private var place: [Prayer: PrayerPlace] = Dictionary(uniqueKeysWithValues: Prayer.allCases.map { ($0, .mosque) })
    @State private var sunnahDone: [Prayer: Bool] = Dictionary(uniqueKeysWithValues: Prayer.allCases.map { ($0, true) })

    var body: some View {
        NavigationStack {
            ZStack {
                RamadanBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        headerBlock

                        statsBlock

                        Button {
                            // you can navigate to Insights tab or show sheet later
                        } label: {
                            Text("View Insights")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(RamadanTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(Color.white.opacity(0.12))
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        }
                        .padding(.top, 2)

                        VStack(spacing: 12) {
                            ForEach(Prayer.allCases.sorted(by: { $0.order < $1.order })) { p in
                                PrayerGlassRow(
                                    prayer: p,
                                    timeText: sampleTime(for: p),
                                    isPrayed: store.today.completed.contains(p),
                                    place: Binding(
                                        get: { place[p] ?? .mosque },
                                        set: { place[p] = $0 }
                                    ),
                                    sunnahOn: Binding(
                                        get: { sunnahDone[p] ?? false },
                                        set: { sunnahDone[p] = $0 }
                                    ),
                                    onTogglePrayed: { store.togglePrayer(p) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 26)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(RamadanTheme.textPrimary)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.10)))
                            .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                    }
                }
            }
            .onAppear { store.rollOverIfNeeded() }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(RamadanTheme.gold)
                    .shadow(color: RamadanTheme.gold.opacity(0.25), radius: 10, x: 0, y: 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ramadan Day 1")
                        .ramadanTitle()

                    Text("“Allah loves consistent acts…”")
                        .ramadanSubtitle()
                }

                Spacer()
            }

            Text("Fremont, CA")
                .font(.subheadline)
                .foregroundStyle(RamadanTheme.textTertiary)
        }
    }

    private var statsBlock: some View {
        GlassCard {
            HStack(spacing: 14) {
                ZStack {
                    GoldRing(progress: store.today.completionRatio)
                        .frame(width: 62, height: 62)

                    Text("\(store.today.completed.count)/5")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textPrimary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(store.today.completed.count)/5\nPrayers")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Current Streak 🔥 \(store.streak()) days")
                        .font(.subheadline)
                        .foregroundStyle(RamadanTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Ramadan Streak 🌙 1")
                        .font(.subheadline)
                        .foregroundStyle(RamadanTheme.textSecondary)
                }
            }
        }
    }

    private func sampleTime(for p: Prayer) -> String {
        switch p {
        case .fajr: return "5:26 AM"
        case .dhuhr: return "12:22 PM"
        case .asr: return "4:09 PM"
        case .maghrib: return "5:51 PM"
        case .isha: return "7:18 PM"
        }
    }
}

enum PrayerPlace: String, CaseIterable, Identifiable {
    case mosque = "In Mosque"
    case home = "At Home"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mosque: return "building.columns"
        case .home: return "house"
        }
    }
}

private struct PrayerGlassRow: View {
    let prayer: Prayer
    let timeText: String
    let isPrayed: Bool
    @Binding var place: PrayerPlace
    @Binding var sunnahOn: Bool
    let onTogglePrayed: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 42, height: 42)
                            .overlay(Circle().stroke(Color.white.opacity(0.16), lineWidth: 1))

                        Image(systemName: isPrayed ? "checkmark" : "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isPrayed ? RamadanTheme.green : RamadanTheme.red)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(prayer.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(RamadanTheme.textPrimary)
                        Text(timeText)
                            .font(.subheadline)
                            .foregroundStyle(RamadanTheme.textSecondary)
                    }

                    Spacer()

                    StatusBadge(
                        text: isPrayed ? "Prayed" : "Missed",
                        style: isPrayed ? .prayed : .missed
                    )
                }

                HStack(spacing: 10) {
                    // place chip
                    Button {
                        place = (place == .mosque) ? .home : .mosque
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: place.icon)
                            Text(place.rawValue)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal")
                                .foregroundStyle(RamadanTheme.textSecondary)
                            Text("Sunnah")
                                .foregroundStyle(RamadanTheme.textSecondary)
                        }
                        .font(.subheadline.weight(.semibold))

                        Toggle("", isOn: $sunnahOn)
                            .labelsHidden()
                            .tint(RamadanTheme.green)
                    }
                }

                Button {
                    onTogglePrayed()
                } label: {
                    Text(isPrayed ? "Mark as missed" : "Mark as prayed")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
