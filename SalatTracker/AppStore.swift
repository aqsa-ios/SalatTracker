//
//  AppStore.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import Foundation
import SwiftUI

final class AppStore: ObservableObject {
    @Published private(set) var today: DailyLog
    @Published private(set) var history: [DailyLog] // recent days
    @Published var qada: QadaState
    @Published var duas: [Dua]
    @Published var favoriteDuaIDs: Set<UUID>
    @Published var settings: UserSettings

    private let storage = Storage()

    init() {
        let loaded = storage.loadAll()
        self.today = loaded.today
        self.history = loaded.history
        self.qada = loaded.qada
        self.duas = loaded.duas
        self.favoriteDuaIDs = loaded.favorites
        self.settings = loaded.settings
        rollOverIfNeeded()
    }

    func togglePrayer(_ prayer: Prayer) {
        if today.completed.contains(prayer) {
            today.completed.remove(prayer)
        } else {
            today.completed.insert(prayer)
        }
        persist()
    }

    func setNote(_ text: String, for prayer: Prayer) {
        today.notesByPrayer[prayer] = text.trimmingCharacters(in: .whitespacesAndNewlines)
        persist()
    }

    func setQadaRemaining(_ value: Int, for prayer: Prayer) {
        qada.remaining[prayer] = max(0, value)
        persist()
    }

    func setMadeUpToday(_ value: Int, for prayer: Prayer) {
        qada.madeUpToday[prayer] = max(0, value)
        persist()
    }

    func commitMadeUpToday() {
        for p in Prayer.allCases {
            let made = qada.madeUpToday[p] ?? 0
            if made > 0 {
                let current = qada.remaining[p] ?? 0
                qada.remaining[p] = max(0, current - made)
                qada.madeUpToday[p] = 0
            }
        }
        persist()
    }

    func toggleFavorite(_ dua: Dua) {
        if favoriteDuaIDs.contains(dua.id) {
            favoriteDuaIDs.remove(dua.id)
        } else {
            favoriteDuaIDs.insert(dua.id)
        }
        persist()
    }

    func isFavorite(_ dua: Dua) -> Bool {
        favoriteDuaIDs.contains(dua.id)
    }

    func rollOverIfNeeded() {
        let todayID = DateFormatter.yyyyMMdd.string(from: Date())
        if today.id != todayID {
            // move previous today into history
            var newHistory = history
            newHistory.insert(today, at: 0)
            newHistory = Array(newHistory.prefix(60)) // keep 60 days
            history = newHistory

            today = DailyLog(id: todayID, completed: [], notesByPrayer: [:])
            persist()
        }
    }

    func streak() -> Int {
        // streak = consecutive days with all 5 completed
        let logs = [today] + history
        var count = 0
        for log in logs {
            if log.completed.count == Prayer.allCases.count {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    func weeklyCompletionRates() -> [Double] {
        // last 7 days including today
        let logs = ([today] + history).prefix(7)
        return logs.map { $0.completionRatio }
    }

    func exportJSON() -> String {
        let blob = storage.makeBlob(today: today, history: history, qada: qada, duas: duas, favorites: favoriteDuaIDs, settings: settings)
        return storage.export(blob: blob) ?? ""
    }

    func importJSON(_ json: String) -> Bool {
        guard let blob = storage.importBlob(from: json) else { return false }
        today = blob.today
        history = blob.history
        qada = blob.qada
        duas = blob.duas
        favoriteDuaIDs = blob.favorites
        settings = blob.settings
        persist()
        return true
    }

    private func persist() {
        storage.saveAll(today: today, history: history, qada: qada, duas: duas, favorites: favoriteDuaIDs, settings: settings)
    }
}

private final class Storage {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let kToday = "salah_today"
    private let kHistory = "salah_history"
    private let kQada = "salah_qada"
    private let kDuas = "salah_duas"
    private let kFavs = "salah_favorites"
    private let kSettings = "salah_settings"

    struct Blob: Codable {
        var today: DailyLog
        var history: [DailyLog]
        var qada: QadaState
        var duas: [Dua]
        var favorites: Set<UUID>
        var settings: UserSettings
    }

    func makeBlob(today: DailyLog, history: [DailyLog], qada: QadaState, duas: [Dua], favorites: Set<UUID>, settings: UserSettings) -> Blob {
        Blob(today: today, history: history, qada: qada, duas: duas, favorites: favorites, settings: settings)
    }

    func loadAll() -> Blob {
        let todayID = DateFormatter.yyyyMMdd.string(from: Date())
        let defaultToday = DailyLog(id: todayID)
        let defaultHistory: [DailyLog] = []
        let defaultQada = QadaState()
        let defaultDuas = DuaSeed.defaultDuas()
        let defaultFavs: Set<UUID> = []
        let defaultSettings = UserSettings()

        let today = load(DailyLog.self, key: kToday) ?? defaultToday
        let history = load([DailyLog].self, key: kHistory) ?? defaultHistory
        let qada = load(QadaState.self, key: kQada) ?? defaultQada
        let duas = load([Dua].self, key: kDuas) ?? defaultDuas
        let favs = load(Set<UUID>.self, key: kFavs) ?? defaultFavs
        let settings = load(UserSettings.self, key: kSettings) ?? defaultSettings

        return Blob(today: today, history: history, qada: qada, duas: duas, favorites: favs, settings: settings)
    }

    func saveAll(today: DailyLog, history: [DailyLog], qada: QadaState, duas: [Dua], favorites: Set<UUID>, settings: UserSettings) {
        save(today, key: kToday)
        save(history, key: kHistory)
        save(qada, key: kQada)
        save(duas, key: kDuas)
        save(favorites, key: kFavs)
        save(settings, key: kSettings)
    }

    func export(blob: Blob) -> String? {
        do {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(blob)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    func importBlob(from json: String) -> Blob? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? decoder.decode(Blob.self, from: data)
    }

    private func save<T: Codable>(_ value: T, key: String) {
        do {
            let data = try encoder.encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch { }
    }

    private func load<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}

private enum DuaSeed {
    static func defaultDuas() -> [Dua] {
        [
            Dua(
                title: "When anxious or distressed",
                category: .anxiety,
                arabic: "حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
                transliteration: "Hasbiyallahu la ilaha illa Huwa, ‘alayhi tawakkaltu wa Huwa Rabbul-‘Arshil-‘Azim",
                meaning: "Allah is sufficient for me. None has the right to be worshipped except Him. I rely on Him, and He is Lord of the Mighty Throne."
            ),
            Dua(
                title: "Gratitude",
                category: .gratitude,
                arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
                transliteration: "Allahumma a‘inni ‘ala dhikrika wa shukrika wa husni ‘ibadatik",
                meaning: "O Allah, help me remember You, thank You, and worship You in the best manner."
            ),
            Dua(
                title: "Travel",
                category: .traveling,
                arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ",
                transliteration: "Subhanalladhi sakhkhara lana hadha wa ma kunna lahu muqrinin",
                meaning: "Glory is to Him who has subjected this to us, and we could not have done it by ourselves."
            ),
            Dua(
                title: "Fasting: intention reminder",
                category: .fasting,
                arabic: "نَوَيْتُ صَوْمَ غَدٍ",
                transliteration: "Nawaytu sawma ghadin",
                meaning: "I intend to fast tomorrow."
            ),
            Dua(
                title: "Protection",
                category: .protection,
                arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
                transliteration: "A‘udhu bikalimatillahit-tammati min sharri ma khalaq",
                meaning: "I seek refuge in Allah’s perfect words from the evil of what He created."
            )
        ]
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
