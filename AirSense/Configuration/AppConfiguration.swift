// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum AppConfiguration {
    enum BundleIdentifiers {
        static let hostApp = "local.airqualitywidget"
        static let widgetExtension = "\(hostApp).AirSenseWidget"
        static let tests = "\(hostApp).tests"
        static let urlName = "\(hostApp).url"
    }

    enum Keychain {
        static let defaultService = BundleIdentifiers.hostApp
        static let waqiTokenAccount = "waqi-token"
    }

    enum SharedStorage {
        static let root = URL(fileURLWithPath: "/Users/Shared/\(BundleIdentifiers.hostApp)", isDirectory: true)
    }

    enum DeepLinks {
        static let scheme = "airsense"
        static let popover = AppConfiguration.url("\(scheme)://popover")
        static let popoverDetails = AppConfiguration.url("\(scheme)://popover?tab=details")
        static let settings = AppConfiguration.url("\(scheme)://settings")
    }

    private static func url(_ rawValue: String) -> URL {
        guard let url = URL(string: rawValue) else {
            preconditionFailure("Invalid app configuration URL: \(rawValue)")
        }
        return url
    }
}
