// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import Observation
import WidgetKit

enum PopoverState: Equatable {
    case empty
    case loading
    case loaded(AirQualitySnapshot)
    case refreshing(AirQualitySnapshot)
    case stale(AirQualitySnapshot, cachedMinutesAgo: Int)
    case error(message: String, lastGood: AirQualitySnapshot?)
}

@Observable
@MainActor
final class AirQualityViewModel {
    var state: PopoverState = .empty

    @ObservationIgnored private let service: AirQualityService
    @ObservationIgnored private let cache: CacheStore
    @ObservationIgnored private var settings: SettingsStore
    @ObservationIgnored private var refreshTask: Task<Void, Never>?

    private let staleThreshold: TimeInterval = 60 * 60

    init(
        service: AirQualityService,
        cache: CacheStore,
        settings: SettingsStore
    ) {
        self.service = service
        self.cache = cache
        self.settings = settings
    }

    var statusCategory: AQICategory? {
        switch state {
        case .loaded(let snap), .refreshing(let snap), .stale(let snap, _):
            return snap.category
        case .error(_, let last):
            return last?.category
        case .empty, .loading:
            return nil
        }
    }

    var statusValue: Int? {
        switch state {
        case .loaded(let snap), .refreshing(let snap), .stale(let snap, _):
            return snap.aqi
        case .error(_, let last):
            return last?.aqi
        case .empty, .loading:
            return nil
        }
    }

    var statusCityName: String? {
        switch state {
        case .loaded(let snap), .refreshing(let snap), .stale(let snap, _):
            return snap.city.name
        case .error(_, let last):
            return last?.city.name
        case .empty, .loading:
            return nil
        }
    }

    func bootstrap() {
        Task { await self.primeFromCache() }
        refresh()
    }

    func refresh() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            await self.performRefresh()
        }
    }

    private func primeFromCache() async {
        if let snap = await cache.load(), snap.city == settings.selectedCity {
            let age = Date().timeIntervalSince(snap.fetchedAt)
            if age > staleThreshold {
                state = .stale(snap, cachedMinutesAgo: max(0, Int(age / 60)))
            } else if case .empty = state {
                state = .loaded(snap)
            }
        }
    }

    private func performRefresh() async {
        guard let city = settings.selectedCity else {
            state = .empty
            return
        }
        switch state {
        case .loaded(let snap):
            state = .refreshing(snap)
        case .empty, .error:
            state = .loading
        default:
            break
        }
        do {
            let snapshot = try await service.fetchSnapshot(for: city, standard: settings.aqiStandard)
            await cache.save(snapshot)
            state = .loaded(snapshot)
            WidgetCenter.shared.reloadAllTimelines()
        } catch is CancellationError {
            return
        } catch {
            state = .error(message: error.userFacingMessage, lastGood: currentSnapshot())
        }
    }

    private func currentSnapshot() -> AirQualitySnapshot? {
        switch state {
        case .loaded(let s), .refreshing(let s), .stale(let s, _): return s
        case .error(_, let last): return last
        case .empty, .loading: return nil
        }
    }

}
