// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    static let shellPadding: CGFloat = 14
    static let heroColumnWidth: CGFloat = 126
    static let dividerHorizontalPadding: CGFloat = 10
    static let aqiBadgeSize: CGFloat = 58
    static let gridColumnSpacing: CGFloat = 14
    static let gridRowSpacing: CGFloat = 14

    let entry: WidgetEntry

    var body: some View {
        switch entry.state {
        case .loaded(let snap):
            MediumLoadedView(snapshot: snap)
        case .stale(let snap, let minutes):
            MediumStaleView(snapshot: snap, ageMinutes: minutes)
        case .error(let reason):
            MediumErrorView(reason: reason)
        case .noCity:
            MediumNoCityView()
        case .loading:
            MediumLoadingView()
        }
    }
}

// MARK: - Loaded

private struct MediumLoadedView: View {
    let snapshot: AirQualitySnapshot

    var body: some View {
        let category = WidgetCategory.from(snapshot: snapshot)
        WidgetShell(tint: category.color, padding: MediumWidgetView.shellPadding) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    MediumHeroColumn(snapshot: snapshot, category: category)
                        .frame(width: MediumWidgetView.heroColumnWidth, alignment: .leading)
                    Divider()
                        .padding(.horizontal, MediumWidgetView.dividerHorizontalPadding)
                    MediumPollutantGrid(snapshot: snapshot, muted: false)
                }
                Spacer(minLength: 8)
                footer(provider: snapshot.stationName ?? "Open-Meteo")
            }
        }
    }

    private func footer(provider: String) -> some View {
        VStack(spacing: 0) {
            Divider().opacity(0.6)
            HStack {
                Spacer()
                Text("Data by \(provider)")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.top, 5)
        }
    }
}

private struct MediumHeroColumn: View {
    let snapshot: AirQualitySnapshot
    let category: WidgetCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Text(snapshot.city.name)
                    .font(.system(size: 13, weight: .bold))
                    .tracking(-0.3)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(1)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(category.color)
            }
            Spacer(minLength: 6)
            AQIBadgeView(category: category, value: snapshot.aqi, size: MediumWidgetView.aqiBadgeSize, shape: .circle)
            Spacer(minLength: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.label)
                    .font(.system(size: 13, weight: .bold))
                    .tracking(-0.2)
                    .foregroundStyle(category.color)
                    .lineLimit(1)
                UpdatedStamp(date: snapshot.fetchedAt)
            }
        }
    }
}

// MARK: - Stale

private struct MediumStaleView: View {
    let snapshot: AirQualitySnapshot
    let ageMinutes: Int

    var body: some View {
        let category = WidgetCategory.from(snapshot: snapshot)
        WidgetShell(tint: nil, padding: MediumWidgetView.shellPadding) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 5) {
                            Text(snapshot.city.name)
                                .font(.system(size: 13, weight: .bold))
                                .tracking(-0.3)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .layoutPriority(1)
                            StaleBadgeView()
                        }
                        Spacer(minLength: 6)
                        ZStack {
                            AQIBadgeView(
                                category: category,
                                value: snapshot.aqi,
                                size: MediumWidgetView.aqiBadgeSize,
                                shape: .circle
                            )
                            Circle().fill(Color.black.opacity(0.35))
                                .frame(width: MediumWidgetView.aqiBadgeSize, height: MediumWidgetView.aqiBadgeSize)
                                .blendMode(.multiply)
                        }
                        Spacer(minLength: 6)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.label)
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(-0.2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            StaleStamp(ageMinutes: ageMinutes)
                        }
                    }
                    .frame(width: MediumWidgetView.heroColumnWidth, alignment: .leading)

                    Divider().padding(.horizontal, MediumWidgetView.dividerHorizontalPadding)

                    MediumPollutantGrid(snapshot: snapshot, muted: true)
                }
                Spacer(minLength: 8)
                VStack(spacing: 0) {
                    Divider().opacity(0.6)
                    HStack {
                        Spacer()
                        Text("Cached data — tap to refresh")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                    .padding(.top, 5)
                }
            }
        }
    }
}

// MARK: - Error

private struct MediumErrorView: View {
    let reason: String
    var body: some View {
        WidgetShell(tint: nil) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 18) {
                    MediumStatusDisc(systemName: "wifi.slash")
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Air Quality")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(-0.2)
                        Text(reason)
                            .font(.system(size: 13, weight: .bold))
                            .tracking(-0.2)
                        Text("No cached data available. Open AirSense to retry.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 2)
                CtaRow(icon: "arrow.right", title: "Open AirSense")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - No City

private struct MediumNoCityView: View {
    var body: some View {
        WidgetShell(tint: nil) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 18) {
                    MediumStatusDisc(systemName: "location.fill")
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Air Quality")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(-0.2)
                        Text("No city selected")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(-0.2)
                        Text("Choose a city in AirSense Settings to see local air quality.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 2)
                CtaRow(icon: "gearshape.fill", title: "Open Settings")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Loading

private struct MediumLoadingView: View {
    var body: some View {
        WidgetShell(tint: nil, padding: MediumWidgetView.shellPadding) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    RedactedBar(width: 80, height: 11)
                    Spacer(minLength: 6)
                    Circle()
                        .fill(Color.secondary.opacity(0.18))
                        .frame(width: MediumWidgetView.aqiBadgeSize, height: MediumWidgetView.aqiBadgeSize)
                    Spacer(minLength: 6)
                    VStack(alignment: .leading, spacing: 5) {
                        RedactedBar(width: 60, height: 11)
                        RedactedBar(width: 44, height: 9)
                    }
                }
                .frame(width: MediumWidgetView.heroColumnWidth, alignment: .leading)

                Divider().padding(.horizontal, MediumWidgetView.dividerHorizontalPadding)

                LazyVGrid(
                    columns: MediumPollutantGrid.columns,
                    spacing: MediumWidgetView.gridRowSpacing
                ) {
                    ForEach(0..<6, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                RedactedBar(width: 28, height: 9)
                                Spacer()
                                RedactedBar(width: 32, height: 9)
                            }
                            RoundedRectangle(cornerRadius: 2).fill(Color.secondary.opacity(0.18))
                                .frame(height: 3)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Shared medium helpers

private struct MediumPollutantGrid: View {
    let snapshot: AirQualitySnapshot
    let muted: Bool

    static let columns = [
        GridItem(.flexible(), spacing: MediumWidgetView.gridColumnSpacing),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(
            columns: Self.columns,
            spacing: MediumWidgetView.gridRowSpacing
        ) {
            ForEach(Pollutant.allCases, id: \.self) { pollutant in
                PollutantRowView(
                    pollutant: pollutant,
                    value: pollutant.value(from: snapshot.pollutants),
                    units: snapshot.pollutants.units,
                    compact: true
                )
            }
        }
        .opacity(muted ? 0.55 : 1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct MediumStatusDisc: View {
    let systemName: String
    var body: some View {
        ZStack {
            Circle().fill(Color.secondary.opacity(0.10))
                .frame(width: 52, height: 52)
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
        }
    }
}
