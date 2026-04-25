// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI
import WidgetKit

struct AirSenseWidget: Widget {
    static let kind = AppConfiguration.BundleIdentifiers.widgetExtension

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: WidgetProvider()) { entry in
            WidgetRootView(entry: entry)
                .widgetColorScheme(entry.appearance.colorScheme)
                .containerBackground(for: .widget) {
                    WidgetBackground(tint: entry.state.tint)
                        .widgetColorScheme(entry.appearance.colorScheme)
                }
        }
        .configurationDisplayName("AirSense")
        .description("Current air quality for your selected city.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
