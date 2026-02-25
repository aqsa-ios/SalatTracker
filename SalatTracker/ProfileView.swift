//
//  ProfileView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @State private var exportText: String = ""
    @State private var importText: String = ""
    @State private var showExport: Bool = false
    @State private var showImport: Bool = false
    @State private var importResult: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Display") {
                    Toggle("Show transliteration", isOn: Binding(
                        get: { store.settings.showTransliteration },
                        set: { store.settings.showTransliteration = $0 }
                    ))
                    Toggle("Show meaning", isOn: Binding(
                        get: { store.settings.showMeaning },
                        set: { store.settings.showMeaning = $0 }
                    ))
                }

                Section("Data") {
                    Button("Export data") {
                        exportText = store.exportJSON()
                        showExport = true
                    }
                    Button("Import data") {
                        importText = ""
                        importResult = nil
                        showImport = true
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showExport) {
                NavigationStack {
                    VStack(spacing: 12) {
                        Text("Copy this JSON and keep it safe")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextEditor(text: $exportText)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))

                        Spacer()
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showExport = false }
                        }
                    }
                }
            }
            .sheet(isPresented: $showImport) {
                NavigationStack {
                    VStack(spacing: 12) {
                        Text("Paste JSON to restore data")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextEditor(text: $importText)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))

                        if let importResult {
                            Text(importResult)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button("Import") {
                            let ok = store.importJSON(importText)
                            importResult = ok ? "Imported successfully." : "Could not import. Check the JSON."
                        }
                        .buttonStyle(.borderedProminent)

                        Spacer()
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showImport = false }
                        }
                    }
                }
            }
        }
    }
}
