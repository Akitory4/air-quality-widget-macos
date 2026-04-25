// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum SharedStorage {
    static let cacheDirectoryName = "AirSense"
    static let snapshotFileName = "latest-snapshot.json"
    static let appearanceFileName = "appearance.txt"

    static let sharedRoot = AppConfiguration.SharedStorage.root

    enum SettingsKey {
        static let selectedCity = "selectedCity"
        static let aqiStandard = "aqiStandard"
        static let provider = "provider"
    }

    static func defaults() -> UserDefaults { .standard }

    static func containerDirectory() -> URL { sharedRoot }

    static func snapshotURL() -> URL? {
        containerDirectory().appendingPathComponent(snapshotFileName, isDirectory: false)
    }

    static func appearanceURL() -> URL {
        containerDirectory().appendingPathComponent(appearanceFileName, isDirectory: false)
    }
}
