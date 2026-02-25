//
//  InsightGlassView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct InsightsGlassView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                RamadanBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your consistency")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                HStack(spacing: 10) {
                                    InsightTile(title: "Streak", value: "\(store.streak())", icon: "flame.fill")
                                    InsightTile(title: "Today", value: "\(store.today.completed.count)/5", icon: "checkmark.seal.fill")
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Last 7 days")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                let rates = store.weeklyCompletionRates()
                                HStack(alignment: .bottom, spacing: 10) {
                                    ForEach(Array(rates.enumerated()), id: \.offset) { _, r in
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(RamadanTheme.gold.opacity(0.35))
                                            .frame(width: 18, height: max(10, 120 * r))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(RamadanTheme.gold.opacity(0.40), lineWidth: 1)
                                            )
                                    }
                                }

                                Text("Small steps every day beat big bursts.")
                                    .font(.subheadline)
                                    .foregroundStyle(RamadanTheme.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 26)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.rollOverIfNeeded() }
        }
    }
}

private struct InsightTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        GlassCard {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(RamadanTheme.gold)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(RamadanTheme.textSecondary)
                    Text(value)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(RamadanTheme.textPrimary)
                }
                Spacer()
            }
        }
    }
}
