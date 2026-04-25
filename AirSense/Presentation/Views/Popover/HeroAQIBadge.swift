// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct HeroAQIBadge: View {
    let value: Int
    let standard: AQIStandard
    let category: AQICategory
    let updatedText: String

    private var scaleLabel: String {
        switch standard {
        case .european: return L10n.AQI.europeanLabel
        case .usEpa:    return L10n.AQI.usEpaLabel
        }
    }

    private var scaleCaption: String {
        switch standard {
        case .european: return L10n.AQI.europeanScale
        case .usEpa:    return L10n.AQI.usEpaScale
        }
    }

    private var accessibilitySummary: String {
        L10n.AQI.heroBadgeAccessibility(
            standardLabel: scaleLabel,
            value: value,
            category: category.label,
            updatedText: updatedText
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [category.color, category.color.opacity(0.78)],
                            center: UnitPoint(x: 0.35, y: 0.3),
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .shadow(color: category.color.opacity(0.35), radius: 12, y: 6)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                            .blendMode(.plusLighter)
                    }
                VStack(spacing: 3) {
                    Text(verbatim: String(value))
                        .font(.system(size: 40, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(scaleCaption)
                        .font(.system(size: 8, weight: .bold))
                        .kerning(0.3)
                        .foregroundStyle(.white.opacity(0.92))
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                .frame(maxWidth: 60)
            }
            .frame(width: 86, height: 86)

            VStack(alignment: .leading, spacing: 3) {
                Text(scaleLabel)
                    .font(.system(size: 10.5, weight: .semibold))
                    .kerning(0.8)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(category.label)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(category.color)
                    .kerning(-0.5)
                Text(L10n.Common.updated(updatedText))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }
}
