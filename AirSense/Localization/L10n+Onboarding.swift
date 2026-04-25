// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

extension L10n {
    enum Onboarding {
        static let welcomeEyebrow = String(localized: "onboarding.welcome_eyebrow", defaultValue: "First launch")
        static let welcomeTitle = String(localized: "onboarding.welcome_title", defaultValue: "Welcome to AirSense")
        static let welcomeMessage = String(
            localized: "onboarding.welcome_message",
            defaultValue: "A lightweight air-quality companion that lives in your menu bar and keeps current conditions one click away."
        )
        static let pageMenuBarTitle = String(
            localized: "onboarding.page_menu_bar_title",
            defaultValue: "Lives in your menu bar"
        )
        static let pageMenuBarMessage = String(
            localized: "onboarding.page_menu_bar_message",
            defaultValue: "Watch the icon color change with the AQI, open the popover for details, and refresh at any time from the menu."
        )
        static let pageLocationTitle = String(
            localized: "onboarding.page_location_title",
            defaultValue: "Choose the right location"
        )
        static let pageLocationMessage = String(
            localized: "onboarding.page_location_message",
            defaultValue: """
                Search for any city or use your current location from General settings. \
                AirSense refreshes immediately when you switch places.
                """
        )
        static let pageCustomizeTitle = String(localized: "onboarding.page_customize_title", defaultValue: "Tune the widget")
        static let pageCustomizeMessage = String(
            localized: "onboarding.page_customize_message",
            defaultValue: """
                Pick the AQI scale, refresh interval, launch-at-login behavior, \
                and whether the number stays visible in the menu bar.
                """
        )
        static let skip = String(localized: "onboarding.skip", defaultValue: "Skip")
        static let back = String(localized: "onboarding.back", defaultValue: "Back")
        static let next = String(localized: "onboarding.next", defaultValue: "Continue")
        static let finish = String(localized: "onboarding.finish", defaultValue: "Start Using AirSense")
        static let footer = String(
            localized: "onboarding.footer",
            defaultValue: "You can reopen Settings at any time from the menu bar icon."
        )

        static func step(_ current: Int, total: Int) -> String {
            L10n.format(
                String(localized: "onboarding.step_format", defaultValue: "Step %d of %d"),
                current,
                total
            )
        }
    }
}
