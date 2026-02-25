//
//  DuasGlassView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct DuasGlassView: View {
    @EnvironmentObject private var store: AppStore

    @State private var query: String = ""
    @State private var selectedCategory: DuaCategory? = nil
    @State private var favoritesOnly: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                RamadanBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        GlassCard {
                            VStack(spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(RamadanTheme.textSecondary)
                                    TextField("Search duas…", text: $query)
                                        .foregroundStyle(RamadanTheme.textPrimary)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )

                                HStack(spacing: 10) {
                                    Toggle("Favorites", isOn: $favoritesOnly)
                                        .toggleStyle(.button)
                                        .tint(RamadanTheme.gold)

                                    Button {
                                        selectedCategory = nil
                                    } label: {
                                        Text("Clear")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(Color.white.opacity(0.70))
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Browse")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(DuaCategory.allCases) { cat in
                                            Button {
                                                selectedCategory = (selectedCategory == cat) ? nil : cat
                                            } label: {
                                                HStack(spacing: 8) {
                                                    Image(systemName: cat.icon)
                                                    Text(cat.title)
                                                }
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(RamadanTheme.textPrimary)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                        .fill(Color.white.opacity(selectedCategory == cat ? 0.16 : 0.08))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }

                        VStack(spacing: 12) {
                            ForEach(filteredDuas) { dua in
                                NavigationLink {
                                    DuaGlassDetailView(dua: dua)
                                } label: {
                                    GlassCard {
                                        HStack(spacing: 12) {
                                            Image(systemName: dua.category.icon)
                                                .foregroundStyle(RamadanTheme.gold)
                                                .frame(width: 22)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(dua.title)
                                                    .font(.headline.weight(.semibold))
                                                    .foregroundStyle(RamadanTheme.textPrimary)
                                                Text(dua.category.title)
                                                    .font(.subheadline)
                                                    .foregroundStyle(RamadanTheme.textSecondary)
                                            }

                                            Spacer()

                                            Image(systemName: store.isFavorite(dua) ? "heart.fill" : "heart")
                                                .foregroundStyle(RamadanTheme.textSecondary)
                                        }
                                    }
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
            .navigationTitle("Duas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var filteredDuas: [Dua] {
        store.duas.filter { d in
            if favoritesOnly, !store.isFavorite(d) { return false }
            if let selectedCategory, d.category != selectedCategory { return false }
            if query.isEmpty { return true }
            let q = query.lowercased()
            return d.title.lowercased().contains(q)
            || d.meaning.lowercased().contains(q)
            || d.transliteration.lowercased().contains(q)
        }
    }
}

struct DuaGlassDetailView: View {
    @EnvironmentObject private var store: AppStore
    let dua: Dua

    var body: some View {
        ZStack {
            RamadanBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    GlassCard {
                        HStack {
                            Text(dua.title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(RamadanTheme.textPrimary)
                            Spacer()
                            Button {
                                store.toggleFavorite(dua)
                            } label: {
                                Image(systemName: store.isFavorite(dua) ? "heart.fill" : "heart")
                                    .foregroundStyle(RamadanTheme.gold)
                                    .padding(10)
                                    .background(Circle().fill(Color.white.opacity(0.10)))
                                    .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Arabic")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(RamadanTheme.textPrimary)
                            Text(dua.arabic)
                                .font(.title3)
                                .foregroundStyle(RamadanTheme.textPrimary)
                        }
                    }

                    if store.settings.showTransliteration {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Transliteration")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)
                                Text(dua.transliteration)
                                    .foregroundStyle(RamadanTheme.textSecondary)
                            }
                        }
                    }

                    if store.settings.showMeaning {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Meaning")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(RamadanTheme.textPrimary)
                                Text(dua.meaning)
                                    .foregroundStyle(RamadanTheme.textSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 26)
            }
        }
        .navigationTitle("Dua")
        .navigationBarTitleDisplayMode(.inline)
    }
}
