// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct PollutantsGrid: View {
    let pollutants: Pollutants

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(Pollutant.allCases, id: \.self) { pollutant in
                PollutantRow(
                    pollutant: pollutant,
                    value: pollutant.value(from: pollutants),
                    units: pollutants.units
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .overlay(alignment: .top) {
            Divider().opacity(0.6)
        }
    }
}

private struct PollutantRow: View {
    let pollutant: Pollutant
    let value: Double?
    let units: PollutantUnits

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(pollutant.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                if let value {
                    HStack(spacing: 3) {
                        Text(pollutant.formatted(value, kind: units))
                            .font(.system(size: 12, weight: .semibold).monospacedDigit())
                            .foregroundStyle(.primary)
                        Text(pollutant.unit(for: units))
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }
                } else {
                    Text("—")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            SeverityBar(ratio: ratio)
        }
        .padding(.vertical, 3)
    }

    private var ratio: Double {
        guard let value else { return 0 }
        return min(1, max(0, value / pollutant.barMax(for: units)))
    }
}

private struct SeverityBar: View {
    let ratio: Double

    private var color: Color {
        switch ratio {
        case ..<0.17: return Color(hex: 0x7BC96F)
        case ..<0.33: return Color(hex: 0xBBCF4C)
        case ..<0.50: return Color(hex: 0xF7C948)
        case ..<0.67: return Color(hex: 0xF28C28)
        case ..<0.85: return Color(hex: 0xE25C5C)
        default:      return Color(hex: 0x8E3AA8)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.primary.opacity(0.06))
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: proxy.size.width * ratio)
            }
        }
        .frame(height: 4)
    }
}
