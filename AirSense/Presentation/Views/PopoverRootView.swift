// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct PopoverRootView: View {
    @Bindable var viewModel: AirQualityViewModel
    @Bindable var settings: SettingsStore
    let openSettings: () -> Void

    var body: some View {
        Group {
            switch viewModel.state {
            case .empty:
                EmptyStateView(onOpenSettings: openSettings)
            case .loading:
                LoadingStateView(city: L10n.Common.airQuality, coordinates: L10n.Common.fetching)
            case .loaded(let snapshot):
                LoadedPopoverContent(
                    snapshot: snapshot,
                    updatedText: L10n.Common.justNow,
                    footerText: L10n.Common.justNow,
                    refreshing: false,
                    topBanner: nil,
                    onRefresh: viewModel.refresh,
                    onSettings: openSettings
                )
            case .refreshing(let snapshot):
                LoadedPopoverContent(
                    snapshot: snapshot,
                    updatedText: L10n.Common.refreshing,
                    footerText: L10n.Common.justNow,
                    refreshing: true,
                    topBanner: nil,
                    onRefresh: {},
                    onSettings: openSettings
                )
            case .stale(let snapshot, let minutesAgo):
                LoadedPopoverContent(
                    snapshot: snapshot,
                    updatedText: L10n.Common.minutesAgo(minutesAgo),
                    footerText: L10n.Common.minutesAgoOffline(minutesAgo),
                    refreshing: false,
                    topBanner: (.amber, L10n.Popover.staleCachedDataBanner(minutes: minutesAgo)),
                    onRefresh: viewModel.refresh,
                    onSettings: openSettings
                )
            case .error(let message, let lastGood):
                if let lastGood {
                    let minutes = max(0, Int(Date().timeIntervalSince(lastGood.fetchedAt) / 60))
                    LoadedPopoverContent(
                        snapshot: lastGood,
                        updatedText: minutes > 0 ? L10n.Common.minutesAgo(minutes) : L10n.Common.earlier,
                        footerText: L10n.Common.failed,
                        refreshing: false,
                        topBanner: (.red, message),
                        onRefresh: viewModel.refresh,
                        onSettings: openSettings
                    )
                } else {
                    ErrorStateView(
                        city: L10n.Common.airQuality,
                        coordinates: "—",
                        message: message,
                        onRetry: viewModel.refresh
                    )
                }
            }
        }
        .frame(width: PopoverMetrics.width, height: PopoverMetrics.height)
        .background(.regularMaterial)
        .preferredColorScheme(settings.appearance.colorScheme)
    }
}
