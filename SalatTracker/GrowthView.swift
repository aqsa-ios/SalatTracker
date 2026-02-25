//
//  GrowthView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct GrowthView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground() // or AppBackground()
                ScrollView {
                    VStack(spacing: 14) {
                        overviewCard
                        weeklyCard
                        goalsCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Growth")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { store.rollOverIfNeeded() }
        }
    }

    private var overviewCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Overview")
                    .font(.title3.weight(.semibold))

                HStack(spacing: 10) {
                    StatTile(title: "Streak", value: "\(store.streak())")
                    StatTile(title: "Today", value: "\(store.today.completed.count)/5")
                    StatTile(title: "Goal", value: "\(store.settings.dailyGoal)/5")
                }
            }
        }
    }

    private var weeklyCard: some View {
        let rates = store.weeklyCompletionRates() // [Double] 0...1

        return AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Last 7 days")
                    .font(.title3.weight(.semibold))

                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(Array(rates.enumerated()), id: \.offset) { _, r in
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray4))
                            .frame(width: 18, height: max(12, 120 * r))
                    }
                }

                Text("Consistency > perfection.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var goalsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Goals")
                    .font(.title3.weight(.semibold))

                StepperRow(
                    title: "Daily salah goal",
                    subtitle: "Target out of 5",
                    value: Binding(
                        get: { store.settings.dailyGoal },
                        set: { store.settings.dailyGoal = min(5, max(0, $0)) }
                    )
                )

                StepperRow(
                    title: "Qada daily target",
                    subtitle: "How many qada to aim for daily",
                    value: Binding(
                        get: { store.settings.qadaDailyTarget },
                        set: { store.settings.qadaDailyTarget = max(0, $0) }
                    )
                )
            }
        }
    }
}

// Keep this inside GrowthView.swift so it always exists
private struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
        )
    }
}
