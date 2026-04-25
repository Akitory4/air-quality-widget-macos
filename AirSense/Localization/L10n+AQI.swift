// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

extension L10n {
    enum AQI {
        static let europeanLabel = String(localized: "aqi.european_label", defaultValue: "European AQI")
        static let usEpaLabel = String(localized: "aqi.us_epa_label", defaultValue: "US EPA AQI")
        static let europeanScale = String(localized: "aqi.european_scale", defaultValue: "1–6 scale")
        static let usEpaScale = String(localized: "aqi.us_epa_scale", defaultValue: "0–500 scale")
        static let good = String(localized: "aqi.good", defaultValue: "Good")
        static let fair = String(localized: "aqi.fair", defaultValue: "Fair")
        static let moderate = String(localized: "aqi.moderate", defaultValue: "Moderate")
        static let poor = String(localized: "aqi.poor", defaultValue: "Poor")
        static let veryPoor = String(localized: "aqi.very_poor", defaultValue: "Very Poor")
        static let extremelyPoor = String(localized: "aqi.extremely_poor", defaultValue: "Extremely Poor")
        static let recommendationGood = String(
            localized: "aqi.recommendation_good",
            defaultValue: "Air quality is great. Enjoy the outdoors."
        )
        static let recommendationFair = String(
            localized: "aqi.recommendation_fair",
            defaultValue: "Air quality is fine for most people."
        )
        static let recommendationModerate = String(
            localized: "aqi.recommendation_moderate",
            defaultValue: "Air quality is acceptable. Unusually sensitive people should consider reducing long outdoor exertion."
        )
        static let recommendationPoor = String(
            localized: "aqi.recommendation_poor",
            defaultValue: "Sensitive groups should limit prolonged outdoor activity."
        )
        static let recommendationVeryPoor = String(
            localized: "aqi.recommendation_very_poor",
            defaultValue: "Everyone should reduce outdoor exertion; sensitive groups stay inside."
        )
        static let recommendationExtremelyPoor = String(
            localized: "aqi.recommendation_extremely_poor",
            defaultValue: "Health warning: avoid all outdoor exertion."
        )

        static func heroBadgeAccessibility(
            standardLabel: String,
            value: Int,
            category: String,
            updatedText: String
        ) -> String {
            L10n.format(
                String(
                    localized: "aqi.hero_badge_accessibility_format",
                    defaultValue: "%@ %d, %@. Updated %@."
                ),
                standardLabel,
                value,
                category,
                updatedText
            )
        }
    }
}
