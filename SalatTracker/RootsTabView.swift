//
//  RootsTabView.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI

struct RootTabsView: View {

    var body: some View {
        TabView {

            RamadanHomeView()
                .tabItem {
                    Label("Prayers", systemImage: "moon.stars.fill")
                }

            QadaGlassView()
                .tabItem {
                    Label("Qada", systemImage: "clock.arrow.2.circlepath")
                }

            InsightsGlassView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }

            DuasGlassView()
                .tabItem {
                    Label("Duas", systemImage: "hands.sparkles.fill")
                }

            ProfileGlassView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}
