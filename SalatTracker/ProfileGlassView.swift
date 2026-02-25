//
//  ProfileGlassView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct ProfileGlassView: View {
    @EnvironmentObject private var store: AppStore

    @State private var exportText: String = ""
    @State private var showingExport: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                RamadanBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Settings")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                Toggle("Show transliteration", isOn: Binding(
                                    get: { store.settings.showTransliteration },
                                    set: { store.settings.showTransliteration = $0 }
                                ))
                                .tint(RamadanTheme.gold)
                                .foregroundStyle(RamadanTheme.textSecondary)

                                Toggle("Show meaning", isOn: Binding(
                                    get: { store.settings.showMeaning },
                                    set: { store.settings.showMeaning = $0 }
                                ))
                                .tint(RamadanTheme.gold)
                                .foregroundStyle(RamadanTheme.textSecondary)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Data")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                Button {
                                    exportText = store.exportJSON()
                                    showingExport = true
                                } label: {
                                    Text("Export")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.black.opacity(0.85))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Capsule().fill(RamadanTheme.gold))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 26)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingExport) {
                NavigationStack {
                    ZStack {
                        RamadanBackground()
                        VStack(spacing: 12) {
                            Text("Copy your export JSON")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(RamadanTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            TextEditor(text: $exportText)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.white.opacity(0.10))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                                )

                            Spacer()
                        }
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showingExport = false }
                        }
                    }
                }
            }
        }
    }
}
