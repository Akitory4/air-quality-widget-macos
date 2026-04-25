// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI
import WidgetKit

struct WidgetRootView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WidgetEntry

    var body: some View {
        content
            .widgetURL(deepLink)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }

    private var deepLink: URL {
        switch entry.state {
        case .error, .noCity:
            return WidgetDeepLink.settings
        case .loaded, .stale, .loading:
            return family == .systemLarge
                ? WidgetDeepLink.popoverDetails
                : WidgetDeepLink.popover
        }
    }
}
