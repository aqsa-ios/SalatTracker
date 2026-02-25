//
//  DuasView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct DuasView: View {
    @EnvironmentObject private var store: AppStore

    @State private var query: String = ""
    @State private var selectedCategory: DuaCategory? = nil
    @State private var showFavoritesOnly: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground() // or AppBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        controlsCard
                        categoriesCard
                        duaList
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Duas")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var controlsCard: some View {
        AppCard {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search duas…", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )

                HStack(spacing: 10) {
                    Toggle("Favorites", isOn: $showFavoritesOnly)
                        .toggleStyle(.button)

                    Button {
                        selectedCategory = nil
                    } label: {
                        Text("Clear filter")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var categoriesCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Browse")
                    .font(.title3.weight(.semibold))

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
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(selectedCategory == cat ? Color(.systemGray3) : Color(.tertiarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var filtered: [Dua] {
        store.duas.filter { dua in
            if showFavoritesOnly, !store.isFavorite(dua) { return false }
            if let selectedCategory, dua.category != selectedCategory { return false }
            if query.isEmpty { return true }

            let q = query.lowercased()
            return dua.title.lowercased().contains(q)
                || dua.meaning.lowercased().contains(q)
                || dua.transliteration.lowercased().contains(q)
        }
    }

    private var duaList: some View {
        VStack(spacing: 12) {
            ForEach(filtered) { dua in
                NavigationLink {
                    DuaDetailView(dua: dua)
                } label: {
                    AppCard {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.tertiarySystemBackground))
                                    .frame(width: 46, height: 46)

                                Image(systemName: dua.category.icon)
                                    .font(.system(size: 18, weight: .semibold))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(dua.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color(.label))

                                Text(dua.category.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: store.isFavorite(dua) ? "heart.fill" : "heart")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DuaDetailView: View {
    @EnvironmentObject private var store: AppStore
    let dua: Dua

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground() // or AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AppCard {
                            HStack {
                                Text(dua.title)
                                    .font(.title3.weight(.semibold))
                                Spacer()
                                Button {
                                    store.toggleFavorite(dua)
                                } label: {
                                    Image(systemName: store.isFavorite(dua) ? "heart.fill" : "heart")
                                        .font(.title3.weight(.semibold))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Arabic")
                                    .font(.headline.weight(.semibold))
                                Text(dua.arabic)
                                    .font(.title3)
                            }
                        }

                        if store.settings.showTransliteration {
                            AppCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Transliteration")
                                        .font(.headline.weight(.semibold))
                                    Text(dua.transliteration)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        if store.settings.showMeaning {
                            AppCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Meaning")
                                        .font(.headline.weight(.semibold))
                                    Text(dua.meaning)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Dua")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
