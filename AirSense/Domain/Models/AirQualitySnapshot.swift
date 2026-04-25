// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

struct AirQualitySnapshot: Equatable, Codable, Sendable {
    let city: City
    /// Timestamp reported by the upstream API — i.e. when the measurement
    /// itself was taken. For Open-Meteo this is always the top of an
    /// hour, so readings may be up to 60 min old even right after a
    /// successful fetch. Displayed in the popover where "when was this
    /// measured?" matters.
    let observedAt: Date
    /// Wall-clock time on the device when we last successfully pulled
    /// this snapshot from the network. Used for stale-cache detection
    /// and the widget's "Updated N min ago" label — users reading
    /// "Updated 2 min ago" expect it to reflect the last refresh, not
    /// the (often hour-old) upstream observation time.
    let fetchedAt: Date
    let aqi: Int
    let standard: AQIStandard
    let pollutants: Pollutants
    /// WAQI station name when the snapshot came from WAQI — `nil` for
    /// Open-Meteo and for snapshots persisted before P4 (back-compat decode).
    var stationName: String?
    /// Per-station attribution lines required by WAQI ToS (may be empty).
    /// Always `nil` for Open-Meteo; optional to stay back-compatible with
    /// pre-P4 cached snapshots.
    var attributions: [String]?

    init(
        city: City,
        observedAt: Date,
        fetchedAt: Date? = nil,
        aqi: Int,
        standard: AQIStandard,
        pollutants: Pollutants,
        stationName: String? = nil,
        attributions: [String]? = nil
    ) {
        self.city = city
        self.observedAt = observedAt
        self.fetchedAt = fetchedAt ?? Date()
        self.aqi = aqi
        self.standard = standard
        self.pollutants = pollutants
        self.stationName = stationName
        self.attributions = attributions
    }

    enum CodingKeys: String, CodingKey {
        case city, observedAt, fetchedAt, aqi, standard, pollutants, stationName, attributions
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        city = try c.decode(City.self, forKey: .city)
        observedAt = try c.decode(Date.self, forKey: .observedAt)
        fetchedAt = try c.decodeIfPresent(Date.self, forKey: .fetchedAt) ?? observedAt
        aqi = try c.decode(Int.self, forKey: .aqi)
        standard = try c.decode(AQIStandard.self, forKey: .standard)
        pollutants = try c.decode(Pollutants.self, forKey: .pollutants)
        stationName = try c.decodeIfPresent(String.self, forKey: .stationName)
        attributions = try c.decodeIfPresent([String].self, forKey: .attributions)
    }
}
