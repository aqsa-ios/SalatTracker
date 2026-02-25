//
//  TabBarStyle.swift
//  SalatTracker
//
//  Created by Aqsa Khan on 2/19/26.
//
import SwiftUI
import UIKit

struct TabBarStyle {

    static func apply() {

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        // Glass blur background
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.20)

        // Subtle top divider line
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.10)

        // Selected state (gold)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
            red: 0.95,
            green: 0.85,
            blue: 0.55,
            alpha: 1
        )

        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(
                red: 0.95,
                green: 0.85,
                blue: 0.55,
                alpha: 1
            )
        ]

        // Unselected state (bright enough to read)
        let unselectedColor = UIColor.white.withAlphaComponent(0.70)

        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselectedColor
        ]

        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }
}
