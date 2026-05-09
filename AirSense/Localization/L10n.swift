// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum L10n {
    enum Common {
        static let appName = String(localized: "app.name", defaultValue: "AirSense")
        static let airQuality = String(localized: "common.air_quality", defaultValue: "Air Quality")
        static let dataBy = String(localized: "common.data_by", defaultValue: "Data by")
        static let openMeteo = String(localized: "common.open_meteo", defaultValue: "Open-Meteo")
        static let waqi = String(localized: "common.waqi", defaultValue: "WAQI")
        static let attributions = String(localized: "common.attributions", defaultValue: "Attributions")
        static let justNow = String(localized: "common.just_now", defaultValue: "just now")
        static let refreshing = String(localized: "common.refreshing", defaultValue: "refreshing…")
        static let earlier = String(localized: "common.earlier", defaultValue: "earlier")
        static let failed = String(localized: "common.failed", defaultValue: "failed")
        static let fetching = String(localized: "common.fetching", defaultValue: "Fetching…")
        static let loading = String(localized: "common.loading", defaultValue: "Loading…")

        static func updated(_ value: String) -> String {
            L10n.format(
                String(localized: "common.updated_format", defaultValue: "Updated %@"),
                value
            )
        }

        static func minutesAgo(_ minutes: Int) -> String {
            L10n.format(
                String(localized: "common.minutes_ago_format", defaultValue: "%d min ago"),
                minutes
            )
        }

        static func minutesAgoOffline(_ minutes: Int) -> String {
            L10n.format(
                String(localized: "common.minutes_ago_offline_format", defaultValue: "%d min ago · offline"),
                minutes
            )
        }
    }

    enum Popover {
        static let noCitySelected = String(localized: "popover.no_city_selected", defaultValue: "No city selected")
        static let chooseCityToStartTitle = String(localized: "popover.choose_city_title", defaultValue: "Choose a city to start")
        static let chooseCityToStartMessage = String(
            localized: "popover.choose_city_message",
            defaultValue: "Pick your location to see real-time air quality data from Open-Meteo."
        )
        static let openSettings = String(localized: "popover.open_settings", defaultValue: "Open Settings…")
        static let loadingAirQuality = String(localized: "popover.loading_air_quality", defaultValue: "Loading air quality…")
        static let unableToLoad = String(localized: "popover.unable_to_load", defaultValue: "Unable to load")
        static let retry = String(localized: "popover.retry", defaultValue: "Retry")

        static func staleCachedDataBanner(minutes: Int) -> String {
            L10n.format(
                String(
                    localized: "popover.stale_cached_data_banner_format",
                    defaultValue: "No connection — showing cached data from %d min ago"
                ),
                minutes
            )
        }
    }

    enum About {
        static let tagline = String(
            localized: "about.tagline",
            defaultValue: "Native macOS menu-bar air-quality widget."
        )

        static func version(_ version: String, _ build: String) -> String {
            L10n.format(
                String(localized: "about.version_format", defaultValue: "Version %@ (%@)"),
                version,
                build
            )
        }
    }

    enum MenuBar {
        static let refresh = String(localized: "menu.refresh", defaultValue: "Refresh")
        static let checkUpdates = String(localized: "menu.check_updates", defaultValue: "Check updates")
        static let settings = String(localized: "menu.settings", defaultValue: "Settings")
        static let settingsEllipsis = String(localized: "menu.settings_ellipsis", defaultValue: "Settings…")
        static let airQualityAccessibility = String(localized: "menu.air_quality_accessibility", defaultValue: "Air quality")

        static var quitApp: String {
            L10n.format(
                String(localized: "menu.quit_app_format", defaultValue: "Quit %@"),
                Common.appName
            )
        }

        static func aqiTooltip(value: Int, category: String) -> String {
            L10n.format(
                String(localized: "menu.aqi_tooltip_format", defaultValue: "AQI %d — %@"),
                value,
                category
            )
        }

        static func statusItemAccessibility(value: Int, category: String, city: String) -> String {
            L10n.format(
                String(
                    localized: "menu.status_item_accessibility_format",
                    defaultValue: "AQI %d, %@, %@"
                ),
                value,
                category,
                city
            )
        }

        static func statusItemAccessibility(city: String) -> String {
            L10n.format(
                String(
                    localized: "menu.status_item_city_accessibility_format",
                    defaultValue: "Air quality, %@"
                ),
                city
            )
        }
    }

    enum Update {
        static let button = String(localized: "update.button", defaultValue: "Update")
        static let progressPending = String(localized: "update.progress_pending", defaultValue: "…")
        static let notConfigured = String(
            localized: "update.not_configured",
            defaultValue: "Updates are not configured for this build."
        )
        static let informationOnly = String(
            localized: "update.information_only",
            defaultValue: "This update cannot be installed automatically."
        )

        static func updateToVersion(_ version: String) -> String {
            L10n.format(
                String(localized: "update.to_version_format", defaultValue: "Update to version %@"),
                version
            )
        }

        static func configurationFailed(_ reason: String) -> String {
            L10n.format(
                String(localized: "update.configuration_failed_format", defaultValue: "Update configuration failed: %@"),
                reason
            )
        }

        static func failed(_ reason: String) -> String {
            L10n.format(
                String(localized: "update.failed_format", defaultValue: "Update failed: %@"),
                reason
            )
        }

        static func percent(_ value: Int) -> String {
            L10n.format(
                String(localized: "update.percent_format", defaultValue: "%d%%"),
                value
            )
        }
    }

    enum Location {
        static let servicesDisabled = String(
            localized: "location.services_disabled",
            defaultValue: "Location Services are turned off for this Mac."
        )
        static let denied = String(
            localized: "location.denied",
            defaultValue: "Location access was denied. Enable AirSense in Privacy & Security > Location Services."
        )
        static let restricted = String(
            localized: "location.restricted",
            defaultValue: "Location access is restricted on this Mac."
        )
        static let requestInProgress = String(
            localized: "location.request_in_progress",
            defaultValue: "Location is already being requested."
        )
        static let locationUnavailable = String(
            localized: "location.unavailable",
            defaultValue: """
                Couldn't determine your current location. \
                Make sure Location Services is enabled for AirSense in \
                System Settings > Privacy & Security > Location Services, \
                then try again.
                """
        )
        static let unknownAuthorization = String(
            localized: "location.unknown_authorization",
            defaultValue: "AirSense couldn't determine the current authorization state."
        )
    }

    static func format(_ format: String, _ arguments: CVarArg...) -> String {
        String(format: format, locale: Locale.current, arguments: arguments)
    }
}
