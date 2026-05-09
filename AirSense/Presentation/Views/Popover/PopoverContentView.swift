// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct LoadedPopoverContent: View {
    let snapshot: AirQualitySnapshot
    let updatedText: String
    let footerText: String
    let refreshing: Bool
    let topBanner: (BannerTone, String)?
    @ObservedObject var appUpdate: AppUpdateController
    let onRefresh: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(
                city: snapshot.city.displayName,
                coordinates: snapshot.city.formattedCoordinates,
                refreshing: refreshing,
                updateButton: appUpdate.buttonState,
                onRefresh: onRefresh,
                onUpdate: appUpdate.installUpdate,
                onSettings: onSettings
            )
            if refreshing {
                ProgressStrip()
                    .padding(.top, -4)
            }
            if let updateError = appUpdate.errorMessage {
                BannerView(tone: .red, message: updateError)
            }
            if let topBanner {
                BannerView(tone: topBanner.0, message: topBanner.1)
            }
            HeroAQIBadge(
                value: snapshot.aqi,
                standard: snapshot.standard,
                category: snapshot.category,
                updatedText: updatedText
            )
            PollutantsGrid(pollutants: snapshot.pollutants)
            RecommendationBlock(category: snapshot.category, text: snapshot.category.recommendation)
            Spacer(minLength: 0)
            FooterRow(updatedText: footerText, source: FooterSource.from(snapshot))
        }
    }
}

struct EmptyStateView: View {
    @ObservedObject var appUpdate: AppUpdateController
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(
                city: L10n.Common.airQuality,
                coordinates: L10n.Popover.noCitySelected,
                refreshing: false,
                updateButton: appUpdate.buttonState,
                onRefresh: {},
                onUpdate: appUpdate.installUpdate,
                onSettings: onOpenSettings
            )
            if let updateError = appUpdate.errorMessage {
                BannerView(tone: .red, message: updateError)
            }
            Spacer(minLength: 0)
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: 72, height: 72)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 30, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text(L10n.Popover.chooseCityToStartTitle)
                        .font(.system(size: 16, weight: .semibold))
                    Text(L10n.Popover.chooseCityToStartMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 28)
                }
                Button(L10n.Popover.openSettings, action: onOpenSettings)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
            FooterRow(updatedText: "\u{2014}")
        }
    }
}

struct LoadingStateView: View {
    let city: String
    let coordinates: String
    @ObservedObject var appUpdate: AppUpdateController

    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(
                city: city,
                coordinates: coordinates,
                refreshing: false,
                updateButton: appUpdate.buttonState,
                onRefresh: {},
                onUpdate: appUpdate.installUpdate,
                onSettings: {}
            )
            if let updateError = appUpdate.errorMessage {
                BannerView(tone: .red, message: updateError)
            }
            Spacer(minLength: 0)
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.regular)
                Text(L10n.Popover.loadingAirQuality)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            FooterRow(updatedText: "\u{2014}")
        }
    }
}

struct ErrorStateView: View {
    let city: String
    let coordinates: String
    let message: String
    @ObservedObject var appUpdate: AppUpdateController
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(
                city: city,
                coordinates: coordinates,
                refreshing: false,
                updateButton: appUpdate.buttonState,
                onRefresh: onRetry,
                onUpdate: appUpdate.installUpdate,
                onSettings: {}
            )
            if let updateError = appUpdate.errorMessage {
                BannerView(tone: .red, message: updateError)
            }
            BannerView(
                tone: .red,
                message: message,
                action: (label: L10n.Popover.retry, handler: onRetry)
            )
            Spacer(minLength: 0)
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xE25C5C).opacity(0.14))
                        .frame(width: 60, height: 60)
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(Color(hex: 0xE25C5C))
                }
                Text(L10n.Popover.unableToLoad)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.top, 4)
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
            }
            Spacer(minLength: 0)
            FooterRow(updatedText: L10n.Common.failed)
        }
    }
}
