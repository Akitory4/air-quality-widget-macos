// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        switch entry.state {
        case .loaded(let snap):
            LargeLoadedView(snapshot: snap)
        case .stale(let snap, let minutes):
            LargeStaleView(snapshot: snap, ageMinutes: minutes)
        case .error(let reason):
            LargeErrorView(reason: reason)
        case .noCity:
            LargeNoCityView()
        case .loading:
            LargeLoadingView()
        }
    }
}

// MARK: - Loaded

private struct LargeLoadedView: View {
    let snapshot: AirQualitySnapshot

    var body: some View {
        let category = WidgetCategory.from(snapshot: snapshot)
        WidgetShell(tint: category.color) {
            VStack(alignment: .leading, spacing: 0) {
                hero(category: category)
                Divider().padding(.vertical, 10)
                pollutants
                Spacer(minLength: 0)
                HealthRecView(
                    category: category,
                    text: WidgetHealthRecommendation.text(for: category)
                )
                Spacer(minLength: 10)
                footer(provider: snapshot.stationName.map { "Station: \($0)" } ?? "Data by Open-Meteo")
            }
        }
    }

    private func hero(category: WidgetCategory) -> some View {
        HStack(alignment: .center, spacing: 14) {
            AQIBadgeView(category: category, value: snapshot.aqi, size: 80, shape: .squircle)
            VStack(alignment: .leading, spacing: 2) {
                Text(snapshot.standard.widgetHeaderLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
                Text(snapshot.city.name)
                    .font(.system(size: 24, weight: .heavy))
                    .tracking(-0.5)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(category.label)
                    .font(.system(size: 18, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(category.color)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                    Text("Updated \(WidgetRelativeTime.short(snapshot.fetchedAt))")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var pollutants: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())],
            spacing: 8
        ) {
            ForEach(Pollutant.allCases, id: \.self) { pollutant in
                PollutantRowView(
                    pollutant: pollutant,
                    value: pollutant.value(from: snapshot.pollutants),
                    units: snapshot.pollutants.units,
                    compact: false
                )
            }
        }
    }

    private func footer(provider: String) -> some View {
        VStack(spacing: 0) {
            Divider().opacity(0.6).padding(.bottom, 8)
            HStack {
                Text(provider)
                    .font(.system(size: 9.5))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                Spacer()
                HStack(spacing: 3) {
                    Text("AirSense")
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 9))
                }
                .font(.system(size: 9.5))
                .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Stale

private struct LargeStaleView: View {
    let snapshot: AirQualitySnapshot
    let ageMinutes: Int

    var body: some View {
        let category = WidgetCategory.from(snapshot: snapshot)
        WidgetShell(tint: nil) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 14) {
                    ZStack {
                        AQIBadgeView(category: category, value: snapshot.aqi, size: 80, shape: .squircle)
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.black.opacity(0.36))
                            .frame(width: 80, height: 80)
                            .blendMode(.multiply)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(snapshot.standard.widgetHeaderLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                        Text(snapshot.city.name)
                            .font(.system(size: 24, weight: .heavy))
                            .tracking(-0.5)
                            .lineLimit(1)
                        Text(category.label)
                            .font(.system(size: 18, weight: .bold))
                            .tracking(-0.3)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(WidgetPalette.staleText)
                            Text("\(ageMinutes) min ago · stale")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(WidgetPalette.staleText)
                                .monospacedDigit()
                        }
                    }
                    Spacer(minLength: 0)
                    StaleBadgeView()
                }
                Divider().padding(.vertical, 10)
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())],
                    spacing: 8
                ) {
                    ForEach(Pollutant.allCases, id: \.self) { pollutant in
                        PollutantRowView(
                            pollutant: pollutant,
                            value: pollutant.value(from: snapshot.pollutants),
                            units: snapshot.pollutants.units,
                            compact: false
                        )
                    }
                }
                .opacity(0.6)
                Spacer(minLength: 10)
                HealthRecView(
                    category: category,
                    text: "Showing cached data. Last known: "
                        + WidgetHealthRecommendation.text(for: category).lowercasedFirst(),
                    mutedForStale: true
                )
                Spacer(minLength: 10)
                VStack(spacing: 0) {
                    Divider().opacity(0.6).padding(.bottom, 8)
                    HStack {
                        Text("Cached · tap to refresh")
                        Spacer()
                        HStack(spacing: 3) {
                            Text("AirSense")
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 9))
                        }
                    }
                    .font(.system(size: 9.5))
                    .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

// MARK: - Error

private struct LargeErrorView: View {
    let reason: String
    var body: some View {
        WidgetShell(tint: nil) {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Color.secondary.opacity(0.10))
                            .frame(width: 64, height: 64)
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)
                    }
                    VStack(spacing: 6) {
                        Text("AIR QUALITY")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                        Text(reason)
                            .font(.system(size: 20, weight: .bold))
                            .tracking(-0.4)
                        Text("Check your Wi-Fi or network, then tap to open AirSense.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 5) {
                        Text("Open AirSense")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(WidgetPalette.cta)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Divider().opacity(0.6)
                Text("AirSense")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - No City

private struct LargeNoCityView: View {
    var body: some View {
        WidgetShell(tint: nil) {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Color.secondary.opacity(0.10))
                            .frame(width: 64, height: 64)
                        Image(systemName: "location.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)
                    }
                    VStack(spacing: 6) {
                        Text("AIR QUALITY")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                        Text("No city selected")
                            .font(.system(size: 20, weight: .bold))
                            .tracking(-0.4)
                        Text("Pick your city in AirSense to see live air quality data, pollutant breakdown, and health guidance.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Open Settings")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(WidgetPalette.cta)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Divider().opacity(0.6)
                Text("AirSense")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Loading

private struct LargeLoadingView: View {
    var body: some View {
        WidgetShell(tint: nil) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.secondary.opacity(0.18))
                        .frame(width: 80, height: 80)
                    VStack(alignment: .leading, spacing: 8) {
                        RedactedBar(width: 60, height: 10)
                        RedactedBar(width: 130, height: 18)
                        RedactedBar(width: 90, height: 14)
                        RedactedBar(width: 80, height: 10)
                    }
                }
                Divider().padding(.vertical, 12).opacity(0.4)
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(0..<6, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                RedactedBar(width: 30, height: 10)
                                Spacer()
                                RedactedBar(width: 40, height: 10)
                            }
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.secondary.opacity(0.18))
                                .frame(height: 4)
                        }
                    }
                }
                Spacer(minLength: 12)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.secondary.opacity(0.18))
                    .frame(height: 44)
                Spacer(minLength: 12)
                Divider().opacity(0.4)
            }
        }
    }
}

private extension String {
    func lowercasedFirst() -> String {
        guard let first = first else { return self }
        return String(first).lowercased() + dropFirst()
    }
}
