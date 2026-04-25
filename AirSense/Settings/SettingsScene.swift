// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import SwiftUI

struct SettingsScene: View {
    @Bindable var settings: SettingsStore
    let viewModel: AirQualityViewModel
    let citySearch: CitySearchViewModel
    let tokenStore: TokenStore
    let waqiService: AirQualityService

    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        VStack(spacing: 0) {
            SettingsTabStrip(selection: $selectedTab)

            Group {
                switch selectedTab {
                case .general:
                    GeneralTab(settings: settings, viewModel: viewModel, search: citySearch)
                case .dataSource:
                    DataSourceTab(settings: settings, tokenStore: tokenStore, waqiService: waqiService)
                case .about:
                    AboutTab(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            SettingsFooter(settings: settings, onClose: closeWindow)
        }
        .frame(width: 620, height: 520)
    }

    private func closeWindow() {
        NSApp.keyWindow?.performClose(nil)
    }
}

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let onClose: () -> Void

    init(
        settings: SettingsStore,
        viewModel: AirQualityViewModel,
        citySearch: CitySearchViewModel,
        tokenStore: TokenStore,
        waqiService: AirQualityService,
        onClose: @escaping () -> Void
    ) {
        self.onClose = onClose

        let hostingController = NSHostingController(
            rootView: SettingsScene(
                settings: settings,
                viewModel: viewModel,
                citySearch: citySearch,
                tokenStore: tokenStore,
                waqiService: waqiService
            )
        )
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 620, height: 520))
        window.title = L10n.MenuBar.settings
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
