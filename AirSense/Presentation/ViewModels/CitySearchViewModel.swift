// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import Observation

@Observable
@MainActor
final class CitySearchViewModel {
    var searchQuery: String = ""
    private(set) var results: [City] = []
    private(set) var isSearching = false
    private(set) var isLocating = false
    private(set) var searchError: String?

    @ObservationIgnored private let geocoder: GeocodingService
    @ObservationIgnored private let locationService: LocationService

    private static let debounce: Duration = .milliseconds(300)
    private static let minQueryLength = 2

    init(geocoder: GeocodingService, locationService: LocationService) {
        self.geocoder = geocoder
        self.locationService = locationService
    }

    func search() async {
        searchError = nil
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= Self.minQueryLength else {
            results = []
            isSearching = false
            return
        }
        isSearching = true
        defer { isSearching = false }

        do {
            try await Task.sleep(for: Self.debounce)
        } catch {
            return
        }
        if Task.isCancelled { return }

        do {
            let found = try await geocoder.search(query: trimmed)
            if Task.isCancelled { return }
            results = found
        } catch is CancellationError {
            return
        } catch {
            if Task.isCancelled { return }
            results = []
            searchError = L10n.Settings.searchFailed
        }
    }

    func useCurrentLocation(applyingTo settings: SettingsStore) async {
        searchError = nil
        isLocating = true
        defer { isLocating = false }

        do {
            let coordinate = try await locationService.currentLocation()
            let resolvedCity = try await geocoder.reverse(coordinate: coordinate)
            if Task.isCancelled { return }
            settings.selectedCity = LocationSelectionSupport.resolvedCity(
                from: resolvedCity,
                coordinate: coordinate
            )
            searchQuery = ""
            results = []
        } catch is CancellationError {
            return
        } catch {
            if Task.isCancelled { return }
            searchError = LocationSelectionSupport.message(for: error)
        }
    }
}
