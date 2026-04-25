// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import WidgetKit

struct WidgetProvider: TimelineProvider {
    private static let staleThreshold: TimeInterval = 60 * 60

    private static let refreshAfter: TimeInterval = 15 * 60

    func placeholder(in context: Context) -> WidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        if context.isPreview {
            completion(.previewLoaded)
            return
        }
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = currentEntry()
        let nextReload = Date().addingTimeInterval(Self.refreshAfter)
        completion(Timeline(entries: [entry], policy: .after(nextReload)))
    }

    // MARK: - State derivation

    private func currentEntry() -> WidgetEntry {
        let now = Date()
        let appearance = SharedAppearanceStore.load()
        guard let snapshot = loadSnapshot() else {
            return WidgetEntry(date: now, state: .loading, appearance: appearance)
        }
        let age = now.timeIntervalSince(snapshot.fetchedAt)
        if age > Self.staleThreshold {
            let minutes = max(1, Int(age / 60))
            return WidgetEntry(date: now, state: .stale(snapshot, ageMinutes: minutes), appearance: appearance)
        }
        return WidgetEntry(date: now, state: .loaded(snapshot), appearance: appearance)
    }

    private func loadSnapshot() -> AirQualitySnapshot? {
        guard let url = SharedStorage.snapshotURL(),
              let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(AirQualitySnapshot.self, from: data)
    }
}
