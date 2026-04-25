// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class LocationSelectionSupportTests: XCTestCase {
    func test_resolvedCity_prefersReverseGeocodedCity() {
        let coordinate = Coordinate(latitude: 35.18, longitude: 33.36)
        let city = City(
            name: "Nicosia",
            region: "Nicosia, Cyprus",
            country: "CY",
            coordinate: coordinate
        )

        XCTAssertEqual(
            LocationSelectionSupport.resolvedCity(from: city, coordinate: coordinate),
            city
        )
    }

    func test_resolvedCity_fallsBackToCurrentLocation() {
        let coordinate = Coordinate(latitude: 34.7, longitude: 33.1)

        let resolved = LocationSelectionSupport.resolvedCity(from: nil, coordinate: coordinate)

        XCTAssertEqual(resolved.name, L10n.Settings.currentLocation)
        XCTAssertEqual(resolved.coordinate, coordinate)
        XCTAssertNil(resolved.region)
        XCTAssertNil(resolved.country)
    }

    func test_message_forLocationError_usesLocalizedDescription() {
        XCTAssertEqual(
            LocationSelectionSupport.message(for: LocationServiceError.denied),
            LocationServiceError.denied.localizedDescription
        )
    }

    func test_message_forTransportError_mentionsReverseLookup() {
        XCTAssertEqual(
            LocationSelectionSupport.message(for: HTTPError.transport("offline")),
            L10n.Settings.reverseLookupNoConnection
        )
    }
}
