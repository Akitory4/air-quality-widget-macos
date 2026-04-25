// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

@MainActor
final class SettingsStoreTests: XCTestCase {
    private func makeDefaults() -> UserDefaults {
        let suite = "SettingsStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    func test_defaults_whenEmpty() {
        let store = SettingsStore(defaults: makeDefaults(), syncSharedAppearance: false)
        XCTAssertEqual(store.selectedCity, .limassol)
        XCTAssertEqual(store.refreshInterval, .fifteen)
        XCTAssertEqual(store.aqiStandard, .european)
        XCTAssertTrue(store.showValueInMenuBar)
        XCTAssertFalse(store.launchAtLogin)
        XCTAssertFalse(store.hasCompletedOnboarding)
        XCTAssertEqual(store.provider, .openMeteo)
        XCTAssertEqual(store.appearance, .system)
    }

    func test_persists_acrossInstances() {
        let defaults = makeDefaults()
        do {
            let store = SettingsStore(defaults: defaults, syncSharedAppearance: false)
            store.selectedCity = .nicosia
            store.refreshInterval = .thirty
            store.aqiStandard = .usEpa
            store.showValueInMenuBar = false
            store.hasCompletedOnboarding = true
            store.provider = .waqi
            store.appearance = .light
        }
        let reloaded = SettingsStore(defaults: defaults, syncSharedAppearance: false)
        XCTAssertEqual(reloaded.selectedCity, .nicosia)
        XCTAssertEqual(reloaded.refreshInterval, .thirty)
        XCTAssertEqual(reloaded.aqiStandard, .usEpa)
        XCTAssertFalse(reloaded.showValueInMenuBar)
        XCTAssertTrue(reloaded.hasCompletedOnboarding)
        XCTAssertEqual(reloaded.provider, .waqi)
        XCTAssertEqual(reloaded.appearance, .light)
    }

    func test_waqiProvider_normalizesEuropeanStandardOnInit() {
        let defaults = makeDefaults()
        defaults.set(AQIProvider.waqi.rawValue, forKey: "provider")
        defaults.set(AQIStandard.european.rawValue, forKey: "aqiStandard")

        let store = SettingsStore(defaults: defaults, syncSharedAppearance: false)

        XCTAssertEqual(store.provider, .waqi)
        XCTAssertEqual(store.aqiStandard, .usEpa)
        XCTAssertEqual(defaults.string(forKey: "aqiStandard"), AQIStandard.usEpa.rawValue)
    }

    func test_switchingToWAQIProvider_normalizesEuropeanStandard() {
        let store = SettingsStore(defaults: makeDefaults(), syncSharedAppearance: false)
        store.aqiStandard = .european

        store.provider = .waqi

        XCTAssertEqual(store.aqiStandard, .usEpa)
    }

    func test_europeanStandardCannotBeSetWhileProviderIsWAQI() {
        let store = SettingsStore(defaults: makeDefaults(), syncSharedAppearance: false)
        store.provider = .waqi

        store.aqiStandard = .european

        XCTAssertEqual(store.aqiStandard, .usEpa)
    }
}
