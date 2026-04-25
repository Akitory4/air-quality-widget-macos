// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

extension L10n {
    enum Settings {
        static let generalTab = String(localized: "settings.general_tab", defaultValue: "General")
        static let dataSourceTab = String(localized: "settings.data_source_tab", defaultValue: "Data source")
        static let aboutTab = String(localized: "settings.about_tab", defaultValue: "About")
        static let city = String(localized: "settings.city", defaultValue: "City")
        static let searchCities = String(localized: "settings.search_cities", defaultValue: "Search cities…")
        static let noMatches = String(localized: "settings.no_matches", defaultValue: "No matches. Try another name.")
        static let locating = String(localized: "settings.locating", defaultValue: "Locating…")
        static let useMyLocation = String(localized: "settings.use_my_location", defaultValue: "Use my location")
        static let refreshInterval = String(localized: "settings.refresh_interval", defaultValue: "Refresh interval")
        static let appearance = String(localized: "settings.appearance", defaultValue: "Appearance")
        static let appearanceSystem = String(localized: "settings.appearance_system", defaultValue: "System")
        static let appearanceLight = String(localized: "settings.appearance_light", defaultValue: "Light")
        static let appearanceDark = String(localized: "settings.appearance_dark", defaultValue: "Dark")
        static let aqiStandard = String(localized: "settings.aqi_standard", defaultValue: "AQI standard")
        static let europeanAQI = String(localized: "settings.european_aqi", defaultValue: "European AQI (1–6)")
        static let usEpaAQI = String(localized: "settings.us_epa_aqi", defaultValue: "US EPA AQI (0–500)")
        static let aqiStandardDescription = String(
            localized: "settings.aqi_standard_description",
            defaultValue: "Determines which scale is used for the widget and alerts."
        )
        static let aqiStandardWAQIOnly = String(
            localized: "settings.aqi_standard_waqi_only",
            defaultValue: "WAQI reports the US EPA AQI only. Switch to Open-Meteo for the European scale."
        )
        static let menuBar = String(localized: "settings.menu_bar", defaultValue: "Menu bar")
        static let showAQIValue = String(localized: "settings.show_aqi_value", defaultValue: "Show AQI value next to icon")
        static let startup = String(localized: "settings.startup", defaultValue: "Startup")
        static let launchAtLogin = String(localized: "settings.launch_at_login", defaultValue: "Launch at login")
        static let provider = String(localized: "settings.provider", defaultValue: "Provider")
        static let providerOpenMeteo = String(
            localized: "settings.provider_open_meteo",
            defaultValue: "Open-Meteo (no key required)"
        )
        static let providerWAQI = String(
            localized: "settings.provider_waqi",
            defaultValue: "World Air Quality Index (token required)"
        )
        static let providerDescription = String(
            localized: "settings.provider_description",
            defaultValue: """
                Open-Meteo uses the CAMS forecast model on a global grid. \
                WAQI (aqicn.org) aggregates ground stations and usually matches \
                IQAir for the same city, but needs a free token.
                """
        )
        static let waqiTokenLabel = String(
            localized: "settings.waqi_token_label",
            defaultValue: "WAQI token"
        )
        static let waqiTokenPlaceholder = String(
            localized: "settings.waqi_token_placeholder",
            defaultValue: "Paste token here"
        )
        static let waqiTokenSave = String(
            localized: "settings.waqi_token_save",
            defaultValue: "Save"
        )
        static let waqiTokenClear = String(
            localized: "settings.waqi_token_clear",
            defaultValue: "Clear"
        )
        static let waqiGetToken = String(
            localized: "settings.waqi_get_token",
            defaultValue: "Get a free token"
        )
        static let waqiTestConnection = String(
            localized: "settings.waqi_test_connection",
            defaultValue: "Test connection"
        )
        static let waqiTokenSaved = String(
            localized: "settings.waqi_token_saved",
            defaultValue: "Token saved in Keychain."
        )
        static let waqiTokenMissing = String(
            localized: "settings.waqi_token_missing",
            defaultValue: "No token saved yet."
        )
        static let waqiConnectionOK = String(
            localized: "settings.waqi_connection_ok",
            defaultValue: "Connected — last reading looks good."
        )
        static let waqiAttribution = String(
            localized: "settings.waqi_attribution",
            defaultValue: "Data from the World Air Quality Index Project. Station-level attributions appear in the popover."
        )
        static let waqiKeychainUnavailable = String(
            localized: "settings.waqi_keychain_unavailable",
            defaultValue: "Keychain is unavailable. Try again after unlocking your Mac."
        )
        static let searchFailed = String(
            localized: "settings.search_failed",
            defaultValue: "Search failed. Check your connection."
        )
        static let currentLocation = String(localized: "settings.current_location", defaultValue: "Current location")
        static let reverseLookupNoConnection = String(
            localized: "settings.reverse_lookup_no_connection",
            defaultValue: "Found your location, but couldn't resolve the nearest city. Check your connection."
        )
        static let reverseLookupFailed = String(
            localized: "settings.reverse_lookup_failed",
            defaultValue: "Found your location, but couldn't resolve the nearest city right now."
        )
        static let useCurrentLocationFailed = String(
            localized: "settings.use_current_location_failed",
            defaultValue: "Couldn't use your current location right now."
        )

        static func refreshIntervalValue(_ minutes: Int) -> String {
            L10n.format(
                String(localized: "settings.refresh_interval_value_format", defaultValue: "%d min"),
                minutes
            )
        }

        static let cityLabel = String(localized: "settings.city_label", defaultValue: "City:")
        static let refreshIntervalLabel = String(
            localized: "settings.refresh_interval_label",
            defaultValue: "Refresh interval:"
        )
        static let appearanceLabel = String(localized: "settings.appearance_label", defaultValue: "Appearance:")
        static let aqiStandardLabel = String(
            localized: "settings.aqi_standard_label",
            defaultValue: "AQI standard:"
        )
        static let menuBarLabel = String(localized: "settings.menu_bar_label", defaultValue: "Menu bar:")
        static let startupLabel = String(localized: "settings.startup_label", defaultValue: "Startup:")
        static let showAQIValueSubtitle = String(
            localized: "settings.show_aqi_value_subtitle",
            defaultValue: "Adds the current numeric value to the right of the glyph."
        )
        static let europeanAQISubtitle = String(
            localized: "settings.european_aqi_subtitle",
            defaultValue: "Uses EEA thresholds — recommended for Cyprus and the EU."
        )
        static let usEpaAQISubtitle = String(
            localized: "settings.us_epa_aqi_subtitle",
            defaultValue: "Uses NAAQS thresholds — useful for US-based work."
        )
        static func switchToCityPrompt(_ city: String) -> String {
            L10n.format(
                String(localized: "settings.switch_to_city_format", defaultValue: "Switch to %@?"),
                city
            )
        }
        static let switchToCitySubtitle = String(
            localized: "settings.switch_to_city_subtitle",
            defaultValue: "Widget will refresh immediately"
        )
        static let setCity = String(localized: "settings.set_city", defaultValue: "Set City")
        static let cancel = String(localized: "settings.cancel", defaultValue: "Cancel")
        static func locationUpdatedToast(_ city: String) -> String {
            L10n.format(
                String(localized: "settings.location_updated_format", defaultValue: "Location updated to %@"),
                city
            )
        }
        static let close = String(localized: "settings.close", defaultValue: "Close")
    }
}
