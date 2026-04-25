// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum ServiceEndpoints {
    enum OpenMeteo {
        static let website = ServiceEndpoints.url("https://open-meteo.com")
        static let airQualityAPI = ServiceEndpoints.url("https://air-quality-api.open-meteo.com/v1/air-quality")
        static let geocodingSearchAPI = ServiceEndpoints.url("https://geocoding-api.open-meteo.com/v1/search")
        static let geocodingReverseAPI = ServiceEndpoints.url("https://geocoding-api.open-meteo.com/v1/reverse")
    }

    enum WAQI {
        static let website = ServiceEndpoints.url("https://aqicn.org/")
        static let apiBase = ServiceEndpoints.url("https://api.waqi.info")
        static let tokenSignup = ServiceEndpoints.url("https://aqicn.org/data-platform/token/")
    }

    private static func url(_ rawValue: String) -> URL {
        guard let url = URL(string: rawValue) else {
            preconditionFailure("Invalid service endpoint URL: \(rawValue)")
        }
        return url
    }
}
