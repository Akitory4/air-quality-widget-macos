// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

enum PopoverMetrics {
    static let width: CGFloat = 320
    static let height: CGFloat = 420
    static let cornerRadius: CGFloat = 12
}

struct HeaderRow: View {
    let city: String
    let coordinates: String
    let refreshing: Bool
    let updateButton: AppUpdateButtonState
    let onRefresh: () -> Void
    let onUpdate: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(city)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(coordinates)
                    .font(.system(size: 11).monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                IconChipButton(
                    systemName: "arrow.clockwise",
                    accessibilityLabel: L10n.MenuBar.refresh,
                    action: onRefresh
                )
                    .rotationEffect(.degrees(refreshing ? 360 : 0))
                    .animation(
                        refreshing
                            ? .linear(duration: 1.2).repeatForever(autoreverses: false)
                            : .default,
                        value: refreshing
                    )
                if updateButton.isVisible {
                    TextChipButton(
                        title: updateButton.title,
                        accessibilityLabel: updateButton.accessibilityLabel,
                        isDisabled: updateButton.isDisabled,
                        action: onUpdate
                    )
                }
                IconChipButton(
                    systemName: "gearshape",
                    accessibilityLabel: L10n.MenuBar.settings,
                    action: onSettings
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }
}

struct TextChipButton: View {
    let title: String
    let accessibilityLabel: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(isDisabled ? .tertiary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(minWidth: 44, minHeight: 24)
                .padding(.horizontal, 7)
                .background(Color.primary.opacity(isDisabled ? 0.035 : 0.06), in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
        .help(accessibilityLabel)
    }
}

struct IconChipButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .help(accessibilityLabel)
    }
}

enum FooterSource {
    case openMeteo
    case waqi(station: String?)

    static func from(_ snapshot: AirQualitySnapshot) -> FooterSource {
        switch snapshot.pollutants.units {
        case .concentration:    return .openMeteo
        case .usAqiSubIndex:    return .waqi(station: snapshot.stationName)
        }
    }

    var label: String {
        switch self {
        case .openMeteo:               return L10n.Common.openMeteo
        case .waqi(let station?):      return "\(L10n.Common.waqi) — \(station)"
        case .waqi:                    return L10n.Common.waqi
        }
    }

    var url: URL {
        switch self {
        case .openMeteo: return ServiceEndpoints.OpenMeteo.website
        case .waqi:      return ServiceEndpoints.WAQI.website
        }
    }
}

struct FooterRow: View {
    let updatedText: String
    var source: FooterSource = .openMeteo

    var body: some View {
        HStack {
            Text(L10n.Common.updated(updatedText))
            Spacer()
            HStack(spacing: 4) {
                Text(L10n.Common.dataBy)
                Link(source.label, destination: source.url)
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .font(.system(size: 10.5))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .overlay(alignment: .top) {
            Divider().opacity(0.6)
        }
    }
}

enum BannerTone {
    case amber
    case red

    var tint: Color {
        switch self {
        case .amber: return Color(hex: 0xF7C948)
        case .red:   return Color(hex: 0xE25C5C)
        }
    }
    var iconBg: Color {
        switch self {
        case .amber: return Color(hex: 0xF28C28)
        case .red:   return Color(hex: 0xE25C5C)
        }
    }
}

struct BannerView: View {
    let tone: BannerTone
    let message: String
    var action: (label: String, handler: () -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                Circle().fill(tone.iconBg).frame(width: 14, height: 14)
                Text(verbatim: "!")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(message)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(tone.tint.opacity(0.95))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let action {
                Button(action.label, action: action.handler)
                    .buttonStyle(.plain)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundStyle(tone.tint)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(tone.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .leading) {
            Rectangle().fill(tone.tint).frame(width: 2.5)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8))
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }
}

struct ProgressStrip: View {
    @State private var offset: CGFloat = -0.4

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            Rectangle()
                .fill(Color.primary.opacity(0.04))
                .overlay(alignment: .leading) {
                    LinearGradient(
                        colors: [.clear, Color(hex: 0x0A84FF), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width * 0.4)
                    .offset(x: width * offset)
                }
                .clipped()
        }
        .frame(height: 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                offset = 1.0
            }
        }
    }
}
