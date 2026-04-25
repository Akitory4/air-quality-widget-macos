// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

protocol AirQualityService: Sendable {
    func fetchSnapshot(for city: City, standard: AQIStandard) async throws -> AirQualitySnapshot
}

protocol GeocodingService: Sendable {
    func search(query: String) async throws -> [City]
    func reverse(coordinate: Coordinate) async throws -> City?
}
