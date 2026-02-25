//
//  SalatTrackerApp.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//

import SwiftUI

@main
struct SalahTrackerApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environmentObject(store)
        }
    }
}
