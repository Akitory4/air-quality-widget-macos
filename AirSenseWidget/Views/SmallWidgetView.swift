// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: WidgetEntry

    fileprivate static let shellPadding: CGFloat = 18

    var body: some View {
        switch entry.state {
        case .loaded(let snap):
            Loaded(snapshot: snap)
        case .stale(let snap, let minutes):
            Stale(snapshot: snap, ageMinutes: minutes)
        case .error(let reason):
            ErrorView(reason: reason)
        case .noCity:
            NoCityView()
        case .loading:
            LoadingView()
        }
    }

    // MARK: - Loaded

    private struct Loaded: View {
        let snapshot: AirQualitySnapshot

        var body: some View {
            let category = WidgetCategory.from(snapshot: snapshot)
            WidgetShell(tint: category.color, padding: SmallWidgetView.shellPadding) {
                VStack(spacing: 0) {
                    header(category: category)
                    Spacer(minLength: 0)
                    AQIBadgeView(category: category, value: snapshot.aqi, size: 72, shape: .circle)
                    Spacer(minLength: 0)
                    footer(category: category)
                }
            }
        }

        private func header(category: WidgetCategory) -> some View {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(snapshot.city.name)
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(-0.2)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 4)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(category.color)
            }
        }

        private func footer(category: WidgetCategory) -> some View {
            HStack(alignment: .lastTextBaseline) {
                Text(category.label)
                    .font(.system(size: 13, weight: .bold))
                    .tracking(-0.2)
                    .foregroundStyle(category.color)
                    .lineLimit(1)
                Spacer(minLength: 4)
                UpdatedStamp(date: snapshot.fetchedAt, tone: .subtle)
            }
        }
    }

    // MARK: - Stale

    private struct Stale: View {
        let snapshot: AirQualitySnapshot
        let ageMinutes: Int

        var body: some View {
            let category = WidgetCategory.from(snapshot: snapshot)
            WidgetShell(tint: nil, padding: SmallWidgetView.shellPadding) {
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(snapshot.city.name)
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(-0.2)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        StaleBadgeView()
                    }
                    Spacer(minLength: 0)
                    ZStack {
                        AQIBadgeView(category: category, value: snapshot.aqi, size: 72, shape: .circle)
                        Circle().fill(Color.black.opacity(0.32))
                            .frame(width: 72, height: 72)
                            .blendMode(.multiply)
                    }
                    Spacer(minLength: 0)
                    HStack(alignment: .lastTextBaseline) {
                        Text(category.label)
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(-0.2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        StaleStamp(ageMinutes: ageMinutes)
                    }
                }
            }
        }
    }

    // MARK: - Error

    private struct ErrorView: View {
        let reason: String
        var body: some View {
            WidgetShell(tint: nil, padding: SmallWidgetView.shellPadding) {
                VStack(spacing: 0) {
                    Text("Air Quality")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(-0.2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 0)
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 26))
                            .foregroundStyle(.secondary)
                        Text(reason)
                            .font(.system(size: 11.5, weight: .semibold))
                            .tracking(-0.1)
                            .multilineTextAlignment(.center)
                    }
                    Spacer(minLength: 0)
                    CtaRow(icon: "arrow.right", title: "Open AirSense")
                }
            }
        }
    }

    // MARK: - No City

    private struct NoCityView: View {
        var body: some View {
            WidgetShell(tint: nil, padding: SmallWidgetView.shellPadding) {
                VStack(spacing: 0) {
                    Text("Air Quality")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(-0.2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 0)
                    VStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.secondary)
                        Text("No city selected")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer(minLength: 0)
                    CtaRow(icon: "gearshape.fill", title: "Open Settings")
                }
            }
        }
    }

    // MARK: - Loading

    private struct LoadingView: View {
        var body: some View {
            WidgetShell(tint: nil, padding: SmallWidgetView.shellPadding) {
                VStack(spacing: 0) {
                    RedactedBar(width: 90, height: 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 0)
                    Circle()
                        .fill(Color.secondary.opacity(0.18))
                        .frame(width: 72, height: 72)
                    Spacer(minLength: 0)
                    HStack {
                        RedactedBar(width: 64, height: 11)
                        Spacer()
                        RedactedBar(width: 44, height: 9)
                    }
                }
            }
        }
    }
}
