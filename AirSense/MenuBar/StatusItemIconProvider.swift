// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import SwiftUI

enum StatusItemIconProvider {
    @MainActor
    static func configure(
        button: NSStatusBarButton,
        category: AQICategory?,
        value: Int?,
        showValue: Bool,
        city: String?
    ) {
        let symbolName: String
        let tint: NSColor

        if let category {
            switch category {
            case .good, .fair:
                symbolName = "leaf.fill"
            case .moderate, .poor:
                symbolName = "leaf.fill"
            case .veryPoor, .extremelyPoor:
                symbolName = "exclamationmark.triangle.fill"
            }
            tint = NSColor(category.color)
        } else {
            symbolName = "leaf"
            tint = .secondaryLabelColor
        }

        let sizeConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let paletteConfig = NSImage.SymbolConfiguration(paletteColors: [tint])
        let config = sizeConfig.applying(paletteConfig)
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: L10n.MenuBar.airQualityAccessibility)?
            .withSymbolConfiguration(config)
        image?.isTemplate = false
        button.image = image
        button.contentTintColor = nil

        let hasImage = image != nil

        if showValue, let value {
            button.title = " \(value)"
            button.imagePosition = .imageLeft
            let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
            button.attributedTitle = NSAttributedString(
                string: " \(value)",
                attributes: [.font: font, .foregroundColor: NSColor.labelColor]
            )
        } else if hasImage {
            button.title = ""
            button.imagePosition = .imageOnly
        } else {
            // Defensive fallback: guarantee the status item has visible width
            // even if the SF Symbol fails to load.
            button.title = "AQI"
            button.imagePosition = .noImage
        }

        let tooltip = {
            if let category, let value {
                return L10n.MenuBar.aqiTooltip(value: value, category: category.label)
            }
            return L10n.Common.airQuality
        }()
        button.toolTip = tooltip

        let accessibilityLabel = {
            if let category, let value, let city {
                return L10n.MenuBar.statusItemAccessibility(
                    value: value,
                    category: category.label,
                    city: city
                )
            }
            if let city {
                return L10n.MenuBar.statusItemAccessibility(city: city)
            }
            return L10n.Common.airQuality
        }()
        button.setAccessibilityLabel(accessibilityLabel)
    }
}
