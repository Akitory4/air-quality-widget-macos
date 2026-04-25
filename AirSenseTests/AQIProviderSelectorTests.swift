// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

/// Verifies that `AQIProviderSelector` routes `fetchSnapshot` to the
/// concrete backend indicated by `SettingsStore.provider`, and that
/// switching the setting at runtime flips the destination on the next call
/// without any re-wiring.
@MainActor
final class AQIProviderSelectorTests: XCTestCase {

    // MARK: - Fakes

    final class RecordingService: AirQualityService, @unchecked Sendable {
        let label: String
        private(set) var fetchCount = 0
        private(set) var lastStandard: AQIStandard?

        init(label: String) { self.label = label }

        func fetchSnapshot(for city: City, standard: AQIStandard) async throws -> AirQualitySnapshot {
            fetchCount += 1
            lastStandard = standard
            return AirQualitySnapshot(
                city: city,
                observedAt: Date(timeIntervalSince1970: 0),
                aqi: label == "openMeteo" ? 42 : 96,
                standard: standard,
                pollutants: Pollutants(units: label == "openMeteo" ? .concentration : .usAqiSubIndex)
            )
        }
    }

    private func makeSettings(provider: AQIProvider) -> SettingsStore {
        let defaults = UserDefaults(suiteName: "\(AppConfiguration.BundleIdentifiers.tests).\(UUID().uuidString)")!
        defaults.set(provider.rawValue, forKey: "provider")
        return SettingsStore(defaults: defaults, syncSharedAppearance: false)
    }

    // MARK: - Tests

    func test_routes_toOpenMeteo_whenProviderIsOpenMeteo() async throws {
        let openMeteo = RecordingService(label: "openMeteo")
        let waqi = RecordingService(label: "waqi")
        let settings = makeSettings(provider: .openMeteo)
        let selector = AQIProviderSelector(openMeteo: openMeteo, waqi: waqi, settings: settings)

        let snap = try await selector.fetchSnapshot(for: .limassol, standard: .european)

        XCTAssertEqual(openMeteo.fetchCount, 1)
        XCTAssertEqual(waqi.fetchCount, 0)
        XCTAssertEqual(snap.aqi, 42)
        XCTAssertEqual(openMeteo.lastStandard, .european)
    }

    func test_routes_toWAQI_whenProviderIsWAQI() async throws {
        let openMeteo = RecordingService(label: "openMeteo")
        let waqi = RecordingService(label: "waqi")
        let settings = makeSettings(provider: .waqi)
        let selector = AQIProviderSelector(openMeteo: openMeteo, waqi: waqi, settings: settings)

        let snap = try await selector.fetchSnapshot(for: .nicosia, standard: .european)

        XCTAssertEqual(openMeteo.fetchCount, 0)
        XCTAssertEqual(waqi.fetchCount, 1)
        XCTAssertEqual(snap.aqi, 96)
        // European is overridden to US EPA since WAQI can't produce it.
        XCTAssertEqual(waqi.lastStandard, .usEpa)
    }

    func test_flippingProvider_switchesRouteOnNextCall() async throws {
        let openMeteo = RecordingService(label: "openMeteo")
        let waqi = RecordingService(label: "waqi")
        let settings = makeSettings(provider: .openMeteo)
        let selector = AQIProviderSelector(openMeteo: openMeteo, waqi: waqi, settings: settings)

        _ = try await selector.fetchSnapshot(for: .limassol, standard: .usEpa)
        settings.provider = .waqi
        _ = try await selector.fetchSnapshot(for: .limassol, standard: .usEpa)

        XCTAssertEqual(openMeteo.fetchCount, 1)
        XCTAssertEqual(waqi.fetchCount, 1)
    }

    func test_waqi_forcesUSEPA_evenWhenCallerAsksForEuropean() async throws {
        let openMeteo = RecordingService(label: "openMeteo")
        let waqi = RecordingService(label: "waqi")
        let settings = makeSettings(provider: .waqi)
        let selector = AQIProviderSelector(openMeteo: openMeteo, waqi: waqi, settings: settings)

        _ = try await selector.fetchSnapshot(for: .nicosia, standard: .european)

        XCTAssertEqual(waqi.lastStandard, .usEpa, "WAQI cannot produce European AQI")
    }
}
