// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class PollutantsCodingTests: XCTestCase {
    func test_decode_legacySnapshot_withoutUnitsField_defaultsToConcentration() throws {
        // Snapshots cached by the 0.1.0 app have no `units` key.
        // The custom decoder must fall back to `.concentration`.
        let json = """
        {"pm25":18.5,"pm10":34.1,"o3":88.0,"no2":21.0,"so2":4.0,"co":0.3}
        """.data(using: .utf8)!
        let p = try JSONDecoder().decode(Pollutants.self, from: json)
        XCTAssertEqual(p.units, .concentration)
        XCTAssertEqual(p.pm25, 18.5)
    }

    func test_decode_withExplicitUsAqiSubIndex() throws {
        let json = """
        {"pm25":40,"pm10":32,"o3":44,"no2":12,"so2":3,"co":4,"units":"usAqiSubIndex"}
        """.data(using: .utf8)!
        let p = try JSONDecoder().decode(Pollutants.self, from: json)
        XCTAssertEqual(p.units, .usAqiSubIndex)
        XCTAssertEqual(p.pm25, 40)
    }

    func test_roundTrip_preservesUnitsTag() throws {
        let original = Pollutants(pm25: 40, pm10: 32, units: .usAqiSubIndex)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Pollutants.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_pollutantUnitLabel_switchesWithKind() {
        XCTAssertEqual(Pollutant.pm25.unit(for: .concentration), "µg/m³")
        XCTAssertEqual(Pollutant.co.unit(for: .concentration), "mg/m³")
        XCTAssertEqual(Pollutant.pm25.unit(for: .usAqiSubIndex), "AQI")
        XCTAssertEqual(Pollutant.co.unit(for: .usAqiSubIndex), "AQI")
    }
}
