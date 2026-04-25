// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import SwiftUI
import WidgetKit

enum WidgetRenderState: Sendable {
    case loaded(AirQualitySnapshot)
    case stale(AirQualitySnapshot, ageMinutes: Int)
    case error(reason: String)
    case noCity
    case loading

    var tint: Color? {
        switch self {
        case .loaded(let snapshot):
            return WidgetCategory.from(snapshot: snapshot).color
        case .stale, .error, .noCity, .loading:
            return nil
        }
    }
}

struct WidgetEntry: TimelineEntry, Sendable {
    let date: Date
    let state: WidgetRenderState
    let appearance: AppAppearance

    init(date: Date, state: WidgetRenderState, appearance: AppAppearance = .system) {
        self.date = date
        self.state = state
        self.appearance = appearance
    }
}

extension WidgetEntry {
    static let placeholder = WidgetEntry(date: Date(), state: .loading)

    static var previewLoaded: WidgetEntry {
        WidgetEntry(date: Date(), state: .loaded(Self.sampleSnapshot))
    }

    static let sampleSnapshot = AirQualitySnapshot(
        city: .limassol,
        observedAt: Date().addingTimeInterval(-3 * 60),
        aqi: 3,
        standard: .european,
        pollutants: Pollutants(pm25: 18, pm10: 34, o3: 88, no2: 21, so2: 4, co: 0.3)
    )
}
