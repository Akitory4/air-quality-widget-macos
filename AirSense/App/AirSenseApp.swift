// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

@main
struct AirSenseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsScene(
                settings: appDelegate.settings,
                viewModel: appDelegate.viewModel,
                citySearch: appDelegate.citySearch,
                tokenStore: appDelegate.dependencies.tokenStore,
                waqiService: appDelegate.dependencies.waqiService
            )
        }
    }
}
