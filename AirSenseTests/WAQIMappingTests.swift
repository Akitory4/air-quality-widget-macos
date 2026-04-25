// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class WAQIMappingTests: XCTestCase {
    func test_envelope_decodesSuccessShape() throws {
        let json = #"""
        {
          "status": "ok",
          "data": {
            "aqi": 96,
            "idx": 12345,
            "time": { "iso": "2026-04-18T10:00:00Z" },
            "city": { "name": "Nicosia", "geo": [35.17, 33.36] },
            "iaqi": {
              "pm25": { "v": 40.3 },
              "pm10": { "v": 22.0 },
              "o3":   { "v": 18.0 },
              "no2":  { "v": 5.0 },
              "so2":  { "v": 1.0 },
              "co":   { "v": 3.0 }
            },
            "attributions": [
              { "name": "Cyprus EPA", "url": "https://airquality.dli.mlsi.gov.cy/" }
            ]
          }
        }
        """#.data(using: .utf8)!
        let envelope = try JSONDecoder().decode(WAQIEnvelope.self, from: json)
        XCTAssertEqual(envelope.status, "ok")
        guard case .success(let feed) = envelope.data else {
            return XCTFail("Expected success payload")
        }
        XCTAssertEqual(feed.aqi, 96)
        XCTAssertEqual(feed.iaqi?.pm25?.v, 40.3)
        XCTAssertEqual(feed.attributions?.count, 1)
    }

    func test_envelope_decodesFailureShape() throws {
        let json = #"""
        { "status": "error", "data": "Invalid key" }
        """#.data(using: .utf8)!
        let envelope = try JSONDecoder().decode(WAQIEnvelope.self, from: json)
        XCTAssertEqual(envelope.status, "error")
        guard case .failure(let message) = envelope.data else {
            return XCTFail("Expected failure payload")
        }
        XCTAssertEqual(message, "Invalid key")
    }

    func test_map_buildsSnapshotWithUSAQIAndSubIndexUnits() {
        let feed = WAQIFeed(
            aqi: 96,
            idx: 1,
            time: WAQIFeed.Time(iso: "2026-04-18T10:00:00Z"),
            city: WAQIFeed.CityInfo(name: "Nicosia", geo: [35.17, 33.36]),
            iaqi: WAQIFeed.IAQI(
                pm25: .init(v: 40.3),
                pm10: .init(v: 22.0),
                o3:   .init(v: 18.0),
                no2:  .init(v: 5.0),
                so2:  .init(v: 1.0),
                co:   .init(v: 3.0)
            ),
            attributions: nil
        )
        let snap = WAQIAirQualityService.map(feed: feed, fallbackCity: .nicosia)
        XCTAssertEqual(snap.aqi, 96)
        XCTAssertEqual(snap.standard, .usEpa)
        XCTAssertEqual(snap.pollutants.pm25, 40.3)
        XCTAssertEqual(snap.pollutants.units, .usAqiSubIndex)
        XCTAssertEqual(snap.city.name, "Nicosia")
    }

    func test_map_populatesStationAndAttributions() throws {
        let json = #"""
        {
          "status": "ok",
          "data": {
            "aqi": 96,
            "time": { "iso": "2026-04-18T10:00:00Z" },
            "city": { "name": "Nicosia Station" },
            "iaqi": { "pm25": { "v": 40.3 } },
            "attributions": [
              { "name": "Cyprus DLI", "url": "https://dli.example/" },
              { "name": "WAQI",       "url": "https://waqi.info/" }
            ]
          }
        }
        """#.data(using: .utf8)!
        let envelope = try JSONDecoder().decode(WAQIEnvelope.self, from: json)
        guard case .success(let feed) = envelope.data else { return XCTFail("Expected success") }
        let snap = WAQIAirQualityService.map(feed: feed, fallbackCity: .nicosia)
        XCTAssertEqual(snap.stationName, "Nicosia Station")
        XCTAssertEqual(snap.attributions?.count, 2)
        XCTAssertTrue(snap.attributions?.first?.contains("Cyprus DLI") ?? false)
    }

    func test_snapshot_backCompatDecodesWithoutNewKeys() throws {
        let json = #"""
        {
          "city": {
            "id": "34.68,33.04",
            "name": "Limassol",
            "region": "Limassol, Cyprus",
            "country": "CY",
            "coordinate": { "latitude": 34.68, "longitude": 33.04 }
          },
          "observedAt": 0,
          "aqi": 3,
          "standard": "european",
          "pollutants": { "pm25": 18, "pm10": 34 }
        }
        """#.data(using: .utf8)!
        let snap = try JSONDecoder().decode(AirQualitySnapshot.self, from: json)
        XCTAssertEqual(snap.aqi, 3)
        XCTAssertNil(snap.stationName)
        XCTAssertNil(snap.attributions)
        XCTAssertEqual(snap.pollutants.units, .concentration)
    }

    func test_map_fallsBackToNowWhenTimeMissing() {
        let feed = WAQIFeed(aqi: 50, idx: nil, time: nil, city: nil, iaqi: nil, attributions: nil)
        let before = Date()
        let snap = WAQIAirQualityService.map(feed: feed, fallbackCity: .limassol)
        XCTAssertGreaterThanOrEqual(snap.observedAt, before.addingTimeInterval(-1))
        XCTAssertEqual(snap.aqi, 50)
        XCTAssertNil(snap.pollutants.pm25)
    }

    func test_endToEnd_feedJSONPropagatesToSnapshot() throws {
        let json = #"""
        {
          "status": "ok",
          "data": {
            "aqi": 96,
            "time": { "iso": "2026-04-18T10:00:00Z" },
            "iaqi": { "pm25": { "v": 40.3 } }
          }
        }
        """#.data(using: .utf8)!
        let envelope = try JSONDecoder().decode(WAQIEnvelope.self, from: json)
        guard case .success(let feed) = envelope.data else {
            return XCTFail("Expected success payload")
        }
        let snap = WAQIAirQualityService.map(feed: feed, fallbackCity: .nicosia)
        XCTAssertEqual(snap.aqi, 96)
        XCTAssertEqual(snap.pollutants.pm25, 40.3)
        XCTAssertEqual(snap.pollutants.units, .usAqiSubIndex)
    }
}
