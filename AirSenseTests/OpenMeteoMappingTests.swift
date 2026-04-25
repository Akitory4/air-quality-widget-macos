// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class OpenMeteoMappingTests: XCTestCase {
    func test_airQuality_mapsEuropeanAQI() throws {
        let json = """
        {
            "current": {
            "time": "2026-04-18T12:00",
            "european_aqi": 45.0,
            "us_aqi": 72.0,
            "pm2_5": 18.5,
            "pm10": 34.1,
            "ozone": 88.0,
            "nitrogen_dioxide": 21.0,
            "sulphur_dioxide": 4.0,
            "carbon_monoxide": 300.0
          }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(OpenMeteoAirQualityDTO.self, from: json)
        let snap = OpenMeteoAirQualityService.map(dto: dto, city: .limassol, standard: .european)
        XCTAssertEqual(snap.aqi, 3)
        XCTAssertEqual(snap.standard, .european)
        XCTAssertEqual(snap.pollutants.pm25, 18.5)
        XCTAssertEqual(snap.pollutants.co ?? -1, 0.3, accuracy: 0.001)
        XCTAssertEqual(snap.pollutants.units, .concentration)
    }

    func test_airQuality_mapsOpenMeteoEuropeanAQIToOneThroughSixScale() {
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 0), 1)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 19.9), 1)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 20), 2)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 33), 2)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 40), 3)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 60), 4)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 80), 5)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 100), 5)
        XCTAssertEqual(OpenMeteoAirQualityService.europeanAQIBucket(from: 100.1), 6)
    }

    func test_airQuality_mapsUSEPAAQI() throws {
        let json = """
        {
          "current": {
            "time": null,
            "european_aqi": 33.0,
            "us_aqi": 151.6,
            "pm2_5": null, "pm10": null, "ozone": null,
            "nitrogen_dioxide": null, "sulphur_dioxide": null, "carbon_monoxide": null
          }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(OpenMeteoAirQualityDTO.self, from: json)
        let snap = OpenMeteoAirQualityService.map(dto: dto, city: .limassol, standard: .usEpa)
        XCTAssertEqual(snap.aqi, 152)
        XCTAssertEqual(snap.standard, .usEpa)
        XCTAssertEqual(snap.category, .poor)
        XCTAssertNil(snap.pollutants.pm25)
    }

    func test_geocoding_mapsResults() throws {
        let json = """
        {
          "results": [
            {
              "name": "Limassol", "admin1": "Limassol District",
              "country": "Cyprus", "country_code": "CY",
              "latitude": 34.68, "longitude": 33.04
            },
            {
              "name": "Limassol", "admin1": null,
              "country": null, "country_code": null,
              "latitude": 34.0, "longitude": 33.0
            }
          ]
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(OpenMeteoGeocodingDTO.self, from: json)
        let cities = OpenMeteoGeocodingService.map(dto: dto)
        XCTAssertEqual(cities.count, 2)
        XCTAssertEqual(cities[0].name, "Limassol")
        XCTAssertEqual(cities[0].region, "Limassol District, Cyprus")
        XCTAssertEqual(cities[0].country, "CY")
        XCTAssertEqual(cities[0].coordinate.latitude, 34.68)
        XCTAssertNil(cities[1].region)
    }

    func test_geocoding_emptyResults() throws {
        let json = """
        { "results": null }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(OpenMeteoGeocodingDTO.self, from: json)
        XCTAssertTrue(OpenMeteoGeocodingService.map(dto: dto).isEmpty)
    }
}
