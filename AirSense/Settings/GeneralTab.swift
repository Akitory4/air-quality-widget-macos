// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

@MainActor
struct GeneralTab: View {
    @Bindable var settings: SettingsStore
    let viewModel: AirQualityViewModel
    @State var search: CitySearchViewModel
    @State private var launchAtLoginError: String?

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Settings.cityLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    CityPicker(settings: settings, search: search)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                LabeledContent(L10n.Settings.appearanceLabel) {
                    Picker(L10n.Settings.appearance, selection: $settings.appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.label).tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 240)
                }

                LabeledContent(L10n.Settings.refreshIntervalLabel) {
                    Picker(L10n.Settings.refreshInterval, selection: $settings.refreshInterval) {
                        ForEach(RefreshInterval.allCases) { interval in
                            Text(interval.label).tag(interval)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 320)
                }

                LabeledContent(L10n.Settings.aqiStandardLabel) {
                    AQIStandardRadioGroup(
                        selection: $settings.aqiStandard,
                        isEuropeanEnabled: settings.provider.supportsEuropeanAQI
                    )
                }
            }

            Section {
                LabeledContent(L10n.Settings.menuBarLabel) {
                    VStack(alignment: .leading, spacing: 2) {
                        Toggle(L10n.Settings.showAQIValue, isOn: $settings.showValueInMenuBar)
                            .toggleStyle(.switch)
                        Text(L10n.Settings.showAQIValueSubtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                LabeledContent(L10n.Settings.startupLabel) {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle(L10n.Settings.launchAtLogin, isOn: Binding(
                            get: { settings.launchAtLogin },
                            set: { updateLaunchAtLogin($0) }
                        ))
                        .toggleStyle(.switch)

                        if let launchAtLoginError {
                            Text(launchAtLoginError)
                                .font(.system(size: 11))
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .onAppear {
            settings.launchAtLogin = LaunchAtLogin.isEnabled
        }
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            try LaunchAtLogin.setEnabled(enabled)
            settings.launchAtLogin = LaunchAtLogin.isEnabled
            launchAtLoginError = nil
        } catch {
            settings.launchAtLogin = LaunchAtLogin.isEnabled
            launchAtLoginError = L10n.Settings.launchAtLoginFailed(error.localizedDescription)
        }
    }
}

private struct AQIStandardRadioGroup: View {
    @Binding var selection: AQIStandard
    let isEuropeanEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RadioRow(
                isSelected: selection == .european,
                isEnabled: isEuropeanEnabled,
                title: L10n.Settings.europeanAQI,
                subtitle: isEuropeanEnabled
                    ? L10n.Settings.europeanAQISubtitle
                    : L10n.Settings.aqiStandardWAQIOnly
            ) {
                if isEuropeanEnabled { selection = .european }
            }
            RadioRow(
                isSelected: selection == .usEpa,
                isEnabled: true,
                title: L10n.Settings.usEpaAQI,
                subtitle: L10n.Settings.usEpaAQISubtitle
            ) {
                selection = .usEpa
            }
        }
    }
}

private struct RadioRow: View {
    let isSelected: Bool
    let isEnabled: Bool
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                radioBullet
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundStyle(isEnabled ? Color.primary : Color.secondary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var radioBullet: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.primary.opacity(0.25),
                    lineWidth: isSelected ? 4 : 1
                )
                .background(
                    Circle().fill(isSelected ? Color.accentColor : Color.clear)
                )
                .frame(width: 14, height: 14)
            if isSelected {
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(width: 14, height: 16, alignment: .center)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

enum LocationSelectionSupport {
    static func resolvedCity(from geocodedCity: City?, coordinate: Coordinate) -> City {
        geocodedCity ?? City(
            name: L10n.Settings.currentLocation,
            region: nil,
            country: nil,
            coordinate: coordinate
        )
    }

    static func message(for error: Error) -> String {
        if let locationError = error as? LocationServiceError {
            return locationError.localizedDescription
        }

        if let httpError = error as? HTTPError {
            switch httpError {
            case .transport:
                return L10n.Settings.reverseLookupNoConnection
            case .invalidURL, .badStatus, .decoding:
                return L10n.Settings.reverseLookupFailed
            }
        }

        return L10n.Settings.useCurrentLocationFailed
    }
}
