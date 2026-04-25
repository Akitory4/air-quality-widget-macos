// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum PollutantUnits: String, Codable, Sendable {
    case concentration
    case usAqiSubIndex
}

struct Pollutants: Codable, Equatable, Sendable {
    var pm25: Double?
    var pm10: Double?
    var o3: Double?
    var no2: Double?
    var so2: Double?
    var co: Double?
    var units: PollutantUnits

    init(
        pm25: Double? = nil,
        pm10: Double? = nil,
        o3: Double? = nil,
        no2: Double? = nil,
        so2: Double? = nil,
        co: Double? = nil,
        units: PollutantUnits = .concentration
    ) {
        self.pm25 = pm25
        self.pm10 = pm10
        self.o3 = o3
        self.no2 = no2
        self.so2 = so2
        self.co = co
        self.units = units
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.pm25 = try c.decodeIfPresent(Double.self, forKey: .pm25)
        self.pm10 = try c.decodeIfPresent(Double.self, forKey: .pm10)
        self.o3 = try c.decodeIfPresent(Double.self, forKey: .o3)
        self.no2 = try c.decodeIfPresent(Double.self, forKey: .no2)
        self.so2 = try c.decodeIfPresent(Double.self, forKey: .so2)
        self.co = try c.decodeIfPresent(Double.self, forKey: .co)
        self.units = try c.decodeIfPresent(PollutantUnits.self, forKey: .units) ?? .concentration
    }
}

enum Pollutant: String, CaseIterable, Sendable {
    case pm25
    case pm10
    case o3
    case no2
    case so2
    case co

    var label: String {
        switch self {
        case .pm25: return "PM2.5"
        case .pm10: return "PM10"
        case .o3:   return "O\u{2083}"
        case .no2:  return "NO\u{2082}"
        case .so2:  return "SO\u{2082}"
        case .co:   return "CO"
        }
    }

    func unit(for kind: PollutantUnits) -> String {
        switch kind {
        case .concentration:
            return self == .co ? "mg/m³" : "µg/m³"
        case .usAqiSubIndex:
            return "AQI"
        }
    }

    func barMax(for kind: PollutantUnits) -> Double {
        switch kind {
        case .concentration:
            switch self {
            case .pm25: return 75
            case .pm10: return 150
            case .o3:   return 240
            case .no2:  return 200
            case .so2:  return 500
            case .co:   return 20
            }
        case .usAqiSubIndex:
            // US EPA AQI sub-index always maxes at 500; use 300 as the
            // "full bar" threshold so the common 0–300 range uses the
            // visible range without looking permanently empty.
            return 300
        }
    }

    func value(from pollutants: Pollutants) -> Double? {
        switch self {
        case .pm25: return pollutants.pm25
        case .pm10: return pollutants.pm10
        case .o3:   return pollutants.o3
        case .no2:  return pollutants.no2
        case .so2:  return pollutants.so2
        case .co:   return pollutants.co
        }
    }

    func formatted(_ value: Double, kind: PollutantUnits) -> String {
        switch kind {
        case .concentration:
            return self == .co ? String(format: "%.1f", value) : String(format: "%.0f", value)
        case .usAqiSubIndex:
            return String(format: "%.0f", value)
        }
    }
}
