// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct PollutantRowView: View {
    let pollutant: Pollutant
    let value: Double?
    let units: PollutantUnits
    let compact: Bool

    private var labelFont: Font {
        .system(size: compact ? 10.5 : 11, weight: .medium).leading(.tight)
    }
    private var valueFont: Font {
        .system(size: compact ? 11.5 : 11.5, weight: .semibold)
    }
    private var unitFont: Font {
        .system(size: compact ? 9 : 10, weight: .regular)
    }
    private var barHeight: CGFloat { compact ? 3 : 4 }
    private var barRadius: CGFloat { 2 }

    private var ratio: Double {
        guard let value else { return 0 }
        let ceiling = WidgetPollutantSpec.max(for: pollutant, units: units)
        return max(0, min(1, value / ceiling))
    }

    private var barColor: Color {
        switch ratio {
        case ..<0.25:       return Color(hex: 0x50C878)
        case ..<0.5:        return Color(hex: 0xF7C948)
        case ..<0.75:       return Color(hex: 0xFF8C42)
        default:            return Color(hex: 0xE94B4B)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 2 : 3) {
            HStack(alignment: .lastTextBaseline, spacing: compact ? 3 : 4) {
                Text(pollutant.label)
                    .font(labelFont)
                    .tracking(0.1)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(compact ? 0.82 : 0.8)
                    .allowsTightening(true)
                Spacer(minLength: compact ? 1 : 2)
                valueText
            }
            .lineLimit(1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * ratio)
                }
                .clipShape(RoundedRectangle(cornerRadius: barRadius))
            }
            .frame(height: barHeight)
        }
    }

    @ViewBuilder
    private var valueText: some View {
        if let value {
            (Text(pollutant.formatted(value, kind: units))
                .font(valueFont)
                .foregroundColor(.primary)
             + Text(" \(pollutant.unit(for: units))")
                .font(unitFont)
                .foregroundColor(.secondary))
            .lineLimit(1)
            .minimumScaleFactor(compact ? 0.68 : 0.8)
            .allowsTightening(true)
            .monospacedDigit()
            .layoutPriority(2)
        } else {
            Text("—")
                .font(valueFont)
                .foregroundStyle(.tertiary)
        }
    }
}
