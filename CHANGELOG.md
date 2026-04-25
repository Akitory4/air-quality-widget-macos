# Changelog

All notable changes to AirSense are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_No changes yet._

## [0.1.0-beta] — 2026-04-19

First public beta. The app is feature-complete for a personal air-quality menu-bar widget, with an optional higher-accuracy provider (WAQI) and a polished onboarding/popover flow.

### Added

- Menu-bar status item with AQI category colour and optional numeric value next to the icon.
- Popover: current AQI hero badge, per-pollutant grid (PM2.5, PM10, O₃, NO₂, SO₂, CO) with severity bars, health recommendation, footer with data-source attribution.
- Onboarding window on first launch with a 3-page walkthrough (menu bar, location, customisation) and swipe/keyboard navigation.
- Settings window:
  - **General** — city search (Open-Meteo geocoding + CoreLocation reverse lookup), refresh interval, AQI standard (European / US EPA), "show AQI value in menu bar" toggle, "launch at login" toggle (SMAppService).
  - **Data Source** — provider picker, WAQI token field (Save / Clear / Test connection / "Get a free token" link), attribution footer.
  - **About** — version, tagline, per-station attributions of the currently displayed WAQI snapshot when present.
- **Alternative provider: WAQI (aqicn.org).** Opt-in ground-station data source for higher accuracy vs. the default Open-Meteo forecast model; usually matches IQAir for the same city.
  - `AQIProvider` enum + persisted `SettingsStore.provider` choice (default `.openMeteo`).
  - `AQIProviderSelector` runtime facade so `AirQualityViewModel` is provider-agnostic; switching takes effect on the next refresh with no DI rebuild.
  - Keychain-backed `TokenStore` (`kSecAttrAccessibleAfterFirstUnlock`) with an in-memory fake for tests.
  - `WAQIAirQualityService` with typed `WAQIError` (missingToken / invalidToken / unknownStation / rateLimited / transport / decoding / upstream) and user-facing message strings.
  - `PollutantUnits` tag on `Pollutants` (concentration µg/m³ vs. US-EPA AQI sub-index); the pollutant grid switches its unit label based on the active source.
  - `AirQualitySnapshot` carries optional `stationName` and `attributions` (WAQI ToS compliance); back-compatible decoding for pre-existing cached snapshots.
- Actor-based on-disk cache for the last good snapshot; stale state after 60 minutes with minutes-ago banner.
- Error state shows the actual network/decoding message and a retry action.
- English localisation via `Localizable.xcstrings` and an `L10n` facade.
- App icon (squircle tile, sky-to-green gradient, stylised air-flow curves) and full AppIcon.appiconset from 16pt to 1024pt.
- `make dmg` / `make release` — produces a drag-to-Applications DMG and a ZIP ready to attach to a GitHub Release (ad-hoc signed).
- Sandbox entitlements: `network.client`, `personal-information.location`.

### Changed

- Single composition root (`AppDependencies`) to respect DIP; view models receive dependencies via constructor injection.
- `AppDependencies.live(settings:)` now wires the selector + keychain + both concrete services.
- `GeneralTab` disables the European AQI option (with an inline explanation) when WAQI is the active provider — WAQI only exposes the US EPA scale. Previous choice resumes on switch back to Open-Meteo.
- Extracted `CitySearchViewModel` out of `GeneralTab`; search is driven by `.task(id:)` with a 300 ms debounce.
- Error banner copy is now dynamic (actual error message + real minutes-ago value) instead of the previous hard-coded "last successful update was more than an hour ago".
- Popover footer credits Open-Meteo or WAQI depending on the active source; WAQI footer includes the station name.

### Fixed

- Menu-bar icon rendered as a yellow warning triangle on some palette configurations — switched to `NSImage.SymbolConfiguration(paletteColors:)` with the tint composed at icon-build time and `contentTintColor = nil`; added an "AQI" text fallback if the SF Symbol ever fails to load.
- Sandbox profile previously blocked network and location calls because the entitlements plist was empty — added `network.client` and `personal-information.location`.
- Onboarding window clipped its "Back / Next" action row below the visible area (content was ~500pt tall inside a 420pt window) — window content size bumped to 680×560 and the outer `VStack` no longer uses `.fixedSize(vertical: true)`.
- Onboarding "First Launch" header rendered under the macOS traffic-light buttons with `.fullSizeContentView` — added a 52pt top inset so the content clears the transparent titlebar area.
- Popover AQI hero badge: "0–500 SCALE" caption overflowed the 86pt circle — constrained the inner `VStack` to 60pt and added `minimumScaleFactor` on both the value and caption.
- `MenuBarController` and `RefreshScheduler` deinits perform cleanup via `MainActor.assumeIsolated` instead of `nonisolated(unsafe)` band-aids.
- Observation chain uses an `isObserving` sentinel to prevent leaks when the controller is torn down.
