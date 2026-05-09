# Changelog

All notable changes to AirSense are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] — 2026-05-09

### Added

- Sparkle-backed in-app update flow: AirSense can check the GitHub Pages appcast, show an `Update` button in the menu-bar popover when a newer release is available, download the signed ZIP asset, install it, and relaunch without opening the GitHub Releases page.
- Minimal update progress UI in the popover header, plus a compact error banner when update download or installation fails.
- GitHub Pages appcast publishing support via `docs/appcast.xml` generation and `make release-with-appcast`.

### Changed

- Release builds now accept `SPARKLE_FEED_URL` and `SPARKLE_PUBLIC_ED_KEY` build settings so dev/MVP ad-hoc builds can keep updater configuration explicit.
- Release packaging now re-signs the embedded Sparkle framework and app extension ad-hoc, and disables library validation for the dev/MVP hardened-runtime app so Sparkle can load at launch.
- Release workflow now publishes `docs/appcast.xml` by pushing the `gh-pages` branch instead of using the GitHub Pages deployment API, avoiding first-run Pages API permission failures.
- Release workflow can now be run manually with an existing `release_tag`, allowing a broken release asset and appcast to be republished from the current `main` without moving the tag.
- Sandbox entitlements now include Sparkle installer-launcher mach lookup exceptions required for sandboxed self-updates.

### Fixed

- Sparkle's "You're up to date!" result is now treated as a normal no-update state instead of a red update failure banner.
- Launch-at-login now reconciles the stored preference with the real `SMAppService` status, reports registration failures in Settings, and refreshes the login item registration after app updates.


## [0.1.1] — 2026-04-25

Patch release focused on AQI scale correctness, Launchpad visibility, and release packaging.

### Changed

- Bumped the app marketing version to `0.1.1` while keeping build `2`.
- AirSense now declares the macOS Utilities app category and uses runtime accessory activation instead of `LSUIElement`, so it can appear in Launchpad while still behaving as a menu-bar app.

### Fixed

- Open-Meteo European AQI values are now mapped from the provider's raw `0–100+` scale into AirSense's European `1–6` display scale.
- US EPA AQI mapping remains on the native `0–500` scale and has explicit regression coverage for category boundaries.
- WAQI provider settings now normalize unsupported European AQI selections back to US EPA on load, provider switch, and direct setting changes.
- Release packaging no longer deletes the generated DMG before upload: the workflow now archives once, then separately packages DMG and ZIP assets for GitHub Releases.

### Tests

- Added regression tests for European AQI bucket mapping, US EPA category boundaries, and WAQI AQI-standard normalization.

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
