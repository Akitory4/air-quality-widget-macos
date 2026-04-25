// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

enum AQICategory: String, CaseIterable, Sendable {
    case good
    case fair
    case moderate
    case poor
    case veryPoor
    case extremelyPoor

    var label: String {
        switch self {
        case .good:           return L10n.AQI.good
        case .fair:           return L10n.AQI.fair
        case .moderate:       return L10n.AQI.moderate
        case .poor:           return L10n.AQI.poor
        case .veryPoor:       return L10n.AQI.veryPoor
        case .extremelyPoor:  return L10n.AQI.extremelyPoor
        }
    }

    var color: Color {
        switch self {
        case .good:           return Color(hex: 0x7BC96F)
        case .fair:           return Color(hex: 0xBBCF4C)
        case .moderate:       return Color(hex: 0xF7C948)
        case .poor:           return Color(hex: 0xF28C28)
        case .veryPoor:       return Color(hex: 0xE25C5C)
        case .extremelyPoor:  return Color(hex: 0x8E3AA8)
        }
    }

    var recommendation: String {
        switch self {
        case .good:
            return L10n.AQI.recommendationGood
        case .fair:
            return L10n.AQI.recommendationFair
        case .moderate:
            return L10n.AQI.recommendationModerate
        case .poor:
            return L10n.AQI.recommendationPoor
        case .veryPoor:
            return L10n.AQI.recommendationVeryPoor
        case .extremelyPoor:
            return L10n.AQI.recommendationExtremelyPoor
        }
    }

    static func forEuropean(_ value: Int) -> AQICategory {
        switch value {
        case ..<2:   return .good
        case 2:      return .fair
        case 3:      return .moderate
        case 4:      return .poor
        case 5:      return .veryPoor
        default:     return .extremelyPoor
        }
    }

    static func forUSEPA(_ value: Int) -> AQICategory {
        switch value {
        case ..<51:   return .good
        case ..<101:  return .fair
        case ..<151:  return .moderate
        case ..<201:  return .poor
        case ..<301:  return .veryPoor
        default:      return .extremelyPoor
        }
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension AirQualitySnapshot {
    var category: AQICategory {
        switch standard {
        case .european: return .forEuropean(aqi)
        case .usEpa:    return .forUSEPA(aqi)
        }
    }

    static let limassolSample = AirQualitySnapshot(
        city: .limassol,
        observedAt: Date(),
        aqi: 3,
        standard: .european,
        pollutants: Pollutants(pm25: 18, pm10: 34, o3: 88, no2: 21, so2: 4, co: 0.3)
    )
}
