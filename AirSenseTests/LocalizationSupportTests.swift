// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class LocalizationSupportTests: XCTestCase {
    func test_updatedStatus_usesExpectedEnglishFallback() {
        XCTAssertEqual(L10n.Common.updated(L10n.Common.justNow), "Updated just now")
    }

    func test_staleFooter_usesExpectedEnglishFallback() {
        XCTAssertEqual(L10n.Common.minutesAgoOffline(15), "15 min ago · offline")
    }

    func test_menuTooltip_usesExpectedEnglishFallback() {
        XCTAssertEqual(
            L10n.MenuBar.aqiTooltip(value: 42, category: AQICategory.good.label),
            "AQI 42 — Good"
        )
    }

    func test_statusItemAccessibility_usesExpectedEnglishFallback() {
        XCTAssertEqual(
            L10n.MenuBar.statusItemAccessibility(value: 42, category: AQICategory.good.label, city: "Nicosia"),
            "AQI 42, Good, Nicosia"
        )
    }

    func test_heroBadgeAccessibility_usesExpectedEnglishFallback() {
        XCTAssertEqual(
            L10n.AQI.heroBadgeAccessibility(
                standardLabel: L10n.AQI.europeanLabel,
                value: 3,
                category: AQICategory.moderate.label,
                updatedText: L10n.Common.justNow
            ),
            "European AQI 3, Moderate. Updated just now."
        )
    }
}
