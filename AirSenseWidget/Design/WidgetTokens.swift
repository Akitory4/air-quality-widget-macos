// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

enum WidgetPalette {
    static let cta = Color(hex: 0x0A84FF)
    static let staleText = Color(hex: 0xB8860B)
    static let staleAccent = Color(hex: 0xF7C948)
}

struct WidgetCategory: Sendable, Equatable {
    let value: Int          // 1…6 EAQI bucket (US EPA values are mapped into the same buckets)
    let label: String
    let color: Color
    let textNeedsWhite: Bool
    let standard: AQIStandard

    private struct Bucket {
        let value: Int
        let label: String
        let color: Color
        let textNeedsWhite: Bool
    }

    private static let base: [Bucket] = [
        .init(value: 1, label: "Good", color: Color(hex: 0x50C878), textNeedsWhite: false),
        .init(value: 2, label: "Fair", color: Color(hex: 0x9ACD32), textNeedsWhite: false),
        .init(value: 3, label: "Moderate", color: Color(hex: 0xF7C948), textNeedsWhite: false),
        .init(value: 4, label: "Poor", color: Color(hex: 0xFF8C42), textNeedsWhite: false),
        .init(value: 5, label: "Very Poor", color: Color(hex: 0xE94B4B), textNeedsWhite: true),
        .init(value: 6, label: "Extremely Poor", color: Color(hex: 0x7D2B5C), textNeedsWhite: true)
    ]

    private static func bucket(_ index: Int, standard: AQIStandard) -> WidgetCategory {
        let entry = base[index]
        return WidgetCategory(
            value: entry.value,
            label: entry.label,
            color: entry.color,
            textNeedsWhite: entry.textNeedsWhite,
            standard: standard
        )
    }

    static func forEuropean(_ aqi: Int) -> WidgetCategory {
        let clamped = max(1, min(6, aqi))
        return bucket(clamped - 1, standard: .european)
    }

    static func forUSEPA(_ aqi: Int) -> WidgetCategory {
        let index: Int
        switch aqi {
        case ..<51:   index = 0
        case ..<101:  index = 1
        case ..<151:  index = 2
        case ..<201:  index = 3
        case ..<301:  index = 4
        default:      index = 5
        }
        return bucket(index, standard: .usEpa)
    }

    static func from(snapshot: AirQualitySnapshot) -> WidgetCategory {
        switch snapshot.standard {
        case .european: return forEuropean(snapshot.aqi)
        case .usEpa:    return forUSEPA(snapshot.aqi)
        }
    }

    var numericColor: Color { textNeedsWhite ? .white : Color(hex: 0x1C1C1E) }
    var scaleHintColor: Color {
        textNeedsWhite ? Color.white.opacity(0.85) : Color(hex: 0x1C1C1E).opacity(0.75)
    }
    var scaleHintText: String {
        switch standard {
        case .european: return "1–6"
        case .usEpa:    return "0–500"
        }
    }
}

extension AQIStandard {
    var widgetHeaderLabel: String {
        switch self {
        case .european: return "EUROPEAN AQI"
        case .usEpa:    return "US EPA AQI"
        }
    }
}

struct WidgetPollutantSpec: Sendable {
    let pollutant: Pollutant
    let max: Double

    static let european: [WidgetPollutantSpec] = [
        .init(pollutant: .pm25, max: 75),
        .init(pollutant: .pm10, max: 150),
        .init(pollutant: .o3, max: 240),
        .init(pollutant: .no2, max: 200),
        .init(pollutant: .so2, max: 500),
        .init(pollutant: .co, max: 20)
    ]

    static func max(for pollutant: Pollutant, units: PollutantUnits) -> Double {
        pollutant.barMax(for: units)
    }
}

enum WidgetHealthRecommendation {
    static let lines: [String] = [
        "Air quality is satisfactory. Enjoy outdoor activities freely.",
        "Air quality is acceptable. Sensitive individuals should consider limiting prolonged exertion.",
        "Sensitive groups may experience health effects. General public is unlikely to be affected.",
        "Everyone may begin to experience health effects. Sensitive groups should avoid prolonged exertion.",
        "Health alert: everyone may experience more serious health effects. Avoid prolonged outdoor exertion.",
        "Health warnings of emergency conditions. The entire population is likely to be affected."
    ]

    static func text(for category: WidgetCategory) -> String {
        lines[category.value - 1]
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

enum WidgetDeepLink {
    static let popover = AppConfiguration.DeepLinks.popover
    static let popoverDetails = AppConfiguration.DeepLinks.popoverDetails
    static let settings = AppConfiguration.DeepLinks.settings
}
