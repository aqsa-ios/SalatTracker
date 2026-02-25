//
//  QadaGlassView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct QadaGlassView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                RamadanBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        totalsCard

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Remaining qada")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                ForEach(Prayer.allCases.sorted(by: { $0.order < $1.order })) { p in
                                    QadaStepperRow(
                                        title: p.title,
                                        value: Binding(
                                            get: { store.qada.remaining[p] ?? 0 },
                                            set: { store.setQadaRemaining($0, for: p) }
                                        )
                                    )
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Made up today")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                ForEach(Prayer.allCases.sorted(by: { $0.order < $1.order })) { p in
                                    QadaStepperRow(
                                        title: p.title,
                                        value: Binding(
                                            get: { store.qada.madeUpToday[p] ?? 0 },
                                            set: { store.setMadeUpToday($0, for: p) }
                                        )
                                    )
                                }

                                Button {
                                    store.commitMadeUpToday()
                                } label: {
                                    Text("Apply to remaining")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.black.opacity(0.85))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(RamadanTheme.gold)
                                        )
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 26)
                }
            }
            .navigationTitle("Qada")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var totalsCard: some View {
        let remaining = store.qada.remaining.values.reduce(0, +)
        let today = store.qada.madeUpToday.values.reduce(0, +)

        return GlassCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Remaining total")
                        .font(.subheadline)
                        .foregroundStyle(RamadanTheme.textSecondary)
                    Text("\(remaining)")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Logged today")
                        .font(.subheadline)
                        .foregroundStyle(RamadanTheme.textSecondary)
                    Text("\(today)")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textPrimary)
                }
            }
        }
    }
}

private struct QadaStepperRow: View {
    let title: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(RamadanTheme.textPrimary)

            Spacer()

            HStack(spacing: 10) {
                Button { value = max(0, value - 1) } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                        .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text("\(value)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(RamadanTheme.textPrimary)
                    .frame(minWidth: 30)

                Button { value += 1 } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(0.10)))
                        .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
                .padding(.top, 34),
            alignment: .top
        )
    }
}
