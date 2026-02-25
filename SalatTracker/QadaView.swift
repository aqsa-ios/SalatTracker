//
//  QadaView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct QadaView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                // Background layer
                AppBackground() // change to AppBackground() if you want no mosque

                // Content layer
                ScrollView {
                    VStack(spacing: 14) {
                        totalsCard

                        VStack(spacing: 12) {
                            Text("Remaining qada")
                                .font(.title3.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(Prayer.allCases.sorted { $0.order < $1.order }) { p in
                                StepperRow(
                                    title: p.title,
                                    subtitle: "How many you still owe",
                                    value: Binding(
                                        get: { store.qada.remaining[p] ?? 0 },
                                        set: { store.setQadaRemaining($0, for: p) }
                                    )
                                )
                            }
                        }

                        AppCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Made up today")
                                        .font(.title3.weight(.semibold))
                                    Spacer()
                                }

                                ForEach(Prayer.allCases.sorted { $0.order < $1.order }) { p in
                                    StepperRow(
                                        title: p.title,
                                        subtitle: "Log what you prayed today",
                                        value: Binding(
                                            get: { store.qada.madeUpToday[p] ?? 0 },
                                            set: { store.setMadeUpToday($0, for: p) }
                                        )
                                    )
                                }

                                Button {
                                    store.commitMadeUpToday()
                                } label: {
                                    Label("Apply to remaining", systemImage: "checkmark.seal")
                                }
                                .buttonStyle(PrimaryPillButtonStyle())
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Qada")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var totalsCard: some View {
        let totalRemaining = store.qada.remaining.values.reduce(0, +)
        let todayMade = store.qada.madeUpToday.values.reduce(0, +)

        return AppCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Remaining total")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(totalRemaining)")
                        .font(.largeTitle.weight(.semibold))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Logged today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(todayMade)")
                        .font(.largeTitle.weight(.semibold))
                }
            }
        }
    }
}
