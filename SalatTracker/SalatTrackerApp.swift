//
//  SalatTrackerApp.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//

import SwiftUI

@main
struct SalatTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
