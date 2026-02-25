//
//  Models.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//

import Foundation

enum Prayer: String, CaseIterable, Identifiable, Codable {
    case fajr, dhuhr, asr, maghrib, isha

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fajr: return "Fajr"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }

    var order: Int {
        switch self {
        case .fajr: return 0
        case .dhuhr: return 1
        case .asr: return 2
        case .maghrib: return 3
        case .isha: return 4
        }
    }

    var icon: String {
        // You can replace with custom assets later
        switch self {
        case .fajr: return "sunrise"
        case .dhuhr: return "sun.max"
        case .asr: return "sun.haze"
        case .maghrib: return "sunset"
        case .isha: return "moon.stars"
        }
    }
}

struct DailyLog: Identifiable, Codable {
    let id: String               // yyyy-MM-dd
    var completed: Set<Prayer>
    var notesByPrayer: [Prayer: String]

    init(id: String, completed: Set<Prayer> = [], notesByPrayer: [Prayer: String] = [:]) {
        self.id = id
        self.completed = completed
        self.notesByPrayer = notesByPrayer
    }

    var completionCount: Int { completed.count }
    var completionRatio: Double { Double(completionCount) / Double(Prayer.allCases.count) }
}

struct QadaState: Codable {
    // remaining qada totals
    var remaining: [Prayer: Int] = Dictionary(uniqueKeysWithValues: Prayer.allCases.map { ($0, 0) })
    // made up today
    var madeUpToday: [Prayer: Int] = Dictionary(uniqueKeysWithValues: Prayer.allCases.map { ($0, 0) })
}

enum DuaCategory: String, CaseIterable, Identifiable, Codable {
    case emotions, traveling, fasting, anxiety, gratitude, protection, forgiveness, rizq

    var id: String { rawValue }

    var title: String {
        switch self {
        case .emotions: return "Emotions"
        case .traveling: return "Traveling"
        case .fasting: return "Fasting"
        case .anxiety: return "Anxiety"
        case .gratitude: return "Gratitude"
        case .protection: return "Protection"
        case .forgiveness: return "Forgiveness"
        case .rizq: return "Rizq"
        }
    }

    var icon: String {
        switch self {
        case .emotions: return "heart.text.square"
        case .traveling: return "airplane"
        case .fasting: return "moonphase.waning.crescent"
        case .anxiety: return "brain.head.profile"
        case .gratitude: return "hands.sparkles"
        case .protection: return "shield"
        case .forgiveness: return "sparkles"
        case .rizq: return "bag"
        }
    }
}

struct Dua: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: DuaCategory
    var arabic: String
    var transliteration: String
    var meaning: String

    init(id: UUID = UUID(), title: String, category: DuaCategory, arabic: String, transliteration: String, meaning: String) {
        self.id = id
        self.title = title
        self.category = category
        self.arabic = arabic
        self.transliteration = transliteration
        self.meaning = meaning
    }
}

struct UserSettings: Codable {
    var dailyGoal: Int = 5 // out of 5
    var qadaDailyTarget: Int = 1
    var showTransliteration: Bool = true
    var showMeaning: Bool = true
}
