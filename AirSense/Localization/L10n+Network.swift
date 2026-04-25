// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

extension L10n {
    enum Network {
        static let invalidRequestURL = String(localized: "network.invalid_request_url", defaultValue: "Invalid request URL.")
        static let connectionError = String(
            localized: "network.connection_error",
            defaultValue: "Can't reach the air quality service. Check your connection."
        )
        static let decodingError = String(
            localized: "network.decoding_error",
            defaultValue: "Couldn't read the service response."
        )
        static let couldntFetchData = String(
            localized: "network.couldnt_fetch_data",
            defaultValue: "Couldn't fetch data. Check your connection."
        )

        static func serviceStatus(_ code: Int) -> String {
            L10n.format(
                String(localized: "network.service_status_format", defaultValue: "Service responded with status %d."),
                code
            )
        }

        static let waqiMissingToken = String(
            localized: "network.waqi_missing_token",
            defaultValue: "Add your free WAQI token in Settings → Data Source."
        )
        static let waqiInvalidToken = String(
            localized: "network.waqi_invalid_token",
            defaultValue: "WAQI rejected the token. Check Settings → Data Source."
        )
        static let waqiUnknownStation = String(
            localized: "network.waqi_unknown_station",
            defaultValue: "No WAQI station near this city. Try another city or switch to Open-Meteo."
        )
        static let waqiRateLimited = String(
            localized: "network.waqi_rate_limited",
            defaultValue: "WAQI rate limit reached. Retry in a minute."
        )
        static let waqiTransport = String(
            localized: "network.waqi_transport",
            defaultValue: "Can't reach WAQI. Check your connection."
        )
        static let waqiDecoding = String(
            localized: "network.waqi_decoding",
            defaultValue: "WAQI response not understood."
        )
        static func waqiUpstream(_ message: String) -> String {
            L10n.format(
                String(localized: "network.waqi_upstream_format", defaultValue: "WAQI error: %@"),
                message
            )
        }
    }
}
