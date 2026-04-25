// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

@MainActor
struct AppDependencies {
    let httpClient: HTTPClient
    let airQualityService: AirQualityService
    let waqiService: AirQualityService
    let geocodingService: GeocodingService
    let locationService: LocationService
    let cache: CacheStore
    let tokenStore: TokenStore

    static func live(settings: SettingsStore) -> AppDependencies {
        let httpClient = URLSessionHTTPClient()
        let tokenStore: TokenStore = KeychainTokenStore(
            service: Bundle.main.bundleIdentifier ?? AppConfiguration.Keychain.defaultService,
            account: AppConfiguration.Keychain.waqiTokenAccount
        )
        let openMeteo = OpenMeteoAirQualityService(client: httpClient)
        let waqi = WAQIAirQualityService(client: httpClient, tokenStore: tokenStore)
        let selector = AQIProviderSelector(openMeteo: openMeteo, waqi: waqi, settings: settings)
        return AppDependencies(
            httpClient: httpClient,
            airQualityService: selector,
            waqiService: waqi,
            geocodingService: OpenMeteoGeocodingService(client: httpClient),
            locationService: CoreLocationService(),
            cache: CacheStore(),
            tokenStore: tokenStore
        )
    }
}
