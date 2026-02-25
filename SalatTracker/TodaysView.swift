//
//  TodaysView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedPrayer: Prayer?
    @State private var noteText: String = ""
    @State private var showRemainingOnly: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        heroHeader

                        filterRow

                        VStack(spacing: 12) {
                            ForEach(prayersToShow) { prayer in
                                PrayerCard(
                                    prayer: prayer,
                                    isDone: store.today.completed.contains(prayer),
                                    note: store.today.notesByPrayer[prayer] ?? "",
                                    onToggle: { store.togglePrayer(prayer) },
                                    onNoteTap: {
                                        selectedPrayer = prayer
                                        noteText = store.today.notesByPrayer[prayer] ?? ""
                                    }
                                )
                            }
                        }

                        quickActions
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Salah")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { store.rollOverIfNeeded() }
            .sheet(item: $selectedPrayer) { prayer in
                NoteSheet(
                    prayer: prayer,
                    noteText: $noteText,
                    onCancel: { selectedPrayer = nil },
                    onSave: {
                        store.setNote(noteText, for: prayer)
                        selectedPrayer = nil
                    }
                )
            }
        }
    }

    private var prayersToShow: [Prayer] {
        let all = Prayer.allCases.sorted { $0.order < $1.order }
        if !showRemainingOnly { return all }
        return all.filter { !store.today.completed.contains($0) }
    }

    private var heroHeader: some View {
        AppCard {
            HStack(spacing: 14) {
                ZStack {
                    ProgressRing(progress: store.today.completionRatio, lineWidth: 10)
                        .frame(width: 74, height: 74)

                    VStack(spacing: 2) {
                        Text("\(store.today.completionCount)")
                            .font(.headline.weight(.semibold))
                        Text("of 5")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(Date(), style: .date)
                        .font(.headline.weight(.semibold))

                    HStack(spacing: 10) {
                        StatusChip(text: "Streak \(store.streak())", systemImage: "flame")
                        StatusChip(text: store.today.completionCount == 5 ? "Complete" : "In progress",
                                   systemImage: store.today.completionCount == 5 ? "checkmark.seal" : "hourglass")
                    }
                }
                Spacer()
            }
        }
    }

    private var filterRow: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focus mode")
                        .font(.headline.weight(.semibold))
                    Text("Show only what’s left for today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: $showRemainingOnly)
                    .labelsHidden()
            }
        }
    }

    private var quickActions: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick actions").sectionTitle()

                HStack(spacing: 10) {
                    Button {
                        for p in Prayer.allCases {
                            if !store.today.completed.contains(p) { store.togglePrayer(p) }
                        }
                    } label: {
                        Label("Mark all", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(PrimaryPillButtonStyle())

                    Button {
                        for p in Prayer.allCases {
                            if store.today.completed.contains(p) { store.togglePrayer(p) }
                        }
                    } label: {
                        Label("Reset", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(SecondaryPillButtonStyle())
                }
            }
        }
    }
}

private struct PrayerCard: View {
    let prayer: Prayer
    let isDone: Bool
    let note: String
    let onToggle: () -> Void
    let onNoteTap: () -> Void

    var body: some View {
        AppCard {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                        .frame(width: 46, height: 46)
                    Image(systemName: prayer.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.label))
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(prayer.title)
                            .font(.headline.weight(.semibold))

                        if isDone {
                            StatusChip(text: "Done", systemImage: "checkmark")
                        } else {
                            StatusChip(text: "Pending", systemImage: "circle")
                        }
                    }

                    if note.isEmpty {
                        Text("Add a note (jama’ah, on time, mood, etc.)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Button(action: onNoteTap) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                        .background(Circle().fill(Color(.tertiarySystemBackground)))
                }
                .buttonStyle(.plain)

                Button(action: onToggle) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isDone ? Color(.label) : Color(.systemGray3))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct NoteSheet: View {
    let prayer: Prayer
    @Binding var noteText: String
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 14) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Note for \(prayer.title)")
                                .font(.headline.weight(.semibold))
                            TextEditor(text: $noteText)
                                .frame(minHeight: 180)
                                .scrollContentBackground(.hidden)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.tertiarySystemBackground)))
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel", action: onCancel) }
                ToolbarItem(placement: .topBarTrailing) { Button("Save", action: onSave) }
            }
        }
    }
}
