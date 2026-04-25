// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import Observation

enum RefreshInterval: Int, CaseIterable, Identifiable, Sendable, Codable {
    case five = 5
    case fifteen = 15
    case thirty = 30
    case sixty = 60

    var id: Int { rawValue }
    var label: String { L10n.Settings.refreshIntervalValue(rawValue) }
    var seconds: TimeInterval { TimeInterval(rawValue * 60) }
}

extension AppAppearance {
    var label: String {
        switch self {
        case .system: return L10n.Settings.appearanceSystem
        case .light:  return L10n.Settings.appearanceLight
        case .dark:   return L10n.Settings.appearanceDark
        }
    }
}

private enum SettingsKey {
    static let selectedCity = "selectedCity"
    static let refreshInterval = "refreshInterval"
    static let aqiStandard = "aqiStandard"
    static let showValueInMenuBar = "showValueInMenuBar"
    static let launchAtLogin = "launchAtLogin"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let provider = "provider"
    static let appearance = "appearance"
}

@Observable
final class SettingsStore {
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let syncSharedAppearance: Bool

    var selectedCity: City? {
        didSet { persistCity() }
    }
    var refreshInterval: RefreshInterval {
        didSet { defaults.set(refreshInterval.rawValue, forKey: SettingsKey.refreshInterval) }
    }
    var aqiStandard: AQIStandard {
        didSet { defaults.set(aqiStandard.rawValue, forKey: SettingsKey.aqiStandard) }
    }
    var showValueInMenuBar: Bool {
        didSet { defaults.set(showValueInMenuBar, forKey: SettingsKey.showValueInMenuBar) }
    }
    var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: SettingsKey.launchAtLogin) }
    }
    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: SettingsKey.hasCompletedOnboarding) }
    }
    var provider: AQIProvider {
        didSet { defaults.set(provider.rawValue, forKey: SettingsKey.provider) }
    }
    var appearance: AppAppearance {
        didSet {
            defaults.set(appearance.rawValue, forKey: SettingsKey.appearance)
            if syncSharedAppearance {
                SharedAppearanceStore.save(appearance)
            }
        }
    }

    init(defaults: UserDefaults = .standard, syncSharedAppearance: Bool = true) {
        self.defaults = defaults
        self.syncSharedAppearance = syncSharedAppearance
        self.selectedCity = Self.loadCity(from: defaults) ?? .limassol
        self.refreshInterval = (defaults.object(forKey: SettingsKey.refreshInterval) as? Int)
            .flatMap(RefreshInterval.init(rawValue:)) ?? .fifteen
        self.aqiStandard = (defaults.string(forKey: SettingsKey.aqiStandard))
            .flatMap(AQIStandard.init(rawValue:)) ?? .european
        self.showValueInMenuBar = (defaults.object(forKey: SettingsKey.showValueInMenuBar) as? Bool) ?? true
        self.launchAtLogin = defaults.bool(forKey: SettingsKey.launchAtLogin)
        self.hasCompletedOnboarding = defaults.bool(forKey: SettingsKey.hasCompletedOnboarding)
        self.provider = (defaults.string(forKey: SettingsKey.provider))
            .flatMap(AQIProvider.init(rawValue:)) ?? .openMeteo
        self.appearance = (defaults.string(forKey: SettingsKey.appearance))
            .flatMap(AppAppearance.init(rawValue:)) ?? .system
        if syncSharedAppearance {
            SharedAppearanceStore.save(appearance)
        }
    }

    private func persistCity() {
        guard let selectedCity else {
            defaults.removeObject(forKey: SettingsKey.selectedCity)
            return
        }
        if let data = try? JSONEncoder().encode(selectedCity) {
            defaults.set(data, forKey: SettingsKey.selectedCity)
        }
    }

    private static func loadCity(from defaults: UserDefaults) -> City? {
        guard let data = defaults.data(forKey: SettingsKey.selectedCity) else { return nil }
        return try? JSONDecoder().decode(City.self, from: data)
    }
}
