// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

@MainActor
final class AQIProviderSelector: AirQualityService {
    private let openMeteo: AirQualityService
    private let waqi: AirQualityService
    private let settings: SettingsStore

    init(openMeteo: AirQualityService, waqi: AirQualityService, settings: SettingsStore) {
        self.openMeteo = openMeteo
        self.waqi = waqi
        self.settings = settings
    }

    func fetchSnapshot(for city: City, standard: AQIStandard) async throws -> AirQualitySnapshot {
        let route = settings.provider
        switch route {
        case .openMeteo:
            return try await openMeteo.fetchSnapshot(for: city, standard: standard)
        case .waqi:
            return try await waqi.fetchSnapshot(for: city, standard: .usEpa)
        }
    }
}
