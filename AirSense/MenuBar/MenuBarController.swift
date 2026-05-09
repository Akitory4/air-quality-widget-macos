// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import SwiftUI
import Observation

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let viewModel: AirQualityViewModel
    private let settings: SettingsStore
    private let appUpdate: AppUpdateController
    private let openSettingsAction: () -> Void
    private var eventMonitor: Any?
    private var isObserving = true

    init(
        viewModel: AirQualityViewModel,
        settings: SettingsStore,
        appUpdate: AppUpdateController,
        openSettings: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.settings = settings
        self.appUpdate = appUpdate
        self.openSettingsAction = openSettings
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: PopoverMetrics.width, height: PopoverMetrics.height)
        self.popover = popover

        configureStatusButton()
        installPopoverContent()
        observeViewModel()
    }

    deinit {
        MainActor.assumeIsolated {
            isObserving = false
            if let eventMonitor {
                NSEvent.removeMonitor(eventMonitor)
            }
        }
    }

    private func configureStatusButton() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        refreshStatusIcon()
    }

    private func installPopoverContent() {
        let root = PopoverRootView(
            viewModel: viewModel,
            settings: settings,
            appUpdate: appUpdate,
            openSettings: { [weak self] in
                self?.openSettings()
            }
        )
        let hosting = NSHostingController(rootView: root)
        hosting.view.frame = NSRect(x: 0, y: 0, width: PopoverMetrics.width, height: PopoverMetrics.height)
        hosting.view.appearance = settings.appearance.nsAppearance
        popover.contentViewController = hosting
    }

    private func observeViewModel() {
        guard isObserving else { return }
        withObservationTracking {
            _ = viewModel.statusCategory
            _ = viewModel.statusValue
            _ = viewModel.statusCityName
            _ = settings.showValueInMenuBar
            _ = settings.selectedCity
            _ = settings.appearance
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, self.isObserving else { return }
                self.applyPopoverAppearance()
                self.refreshStatusIcon()
                self.observeViewModel()
            }
        }
    }

    private func applyPopoverAppearance() {
        popover.contentViewController?.view.appearance = settings.appearance.nsAppearance
    }

    private func refreshStatusIcon() {
        guard let button = statusItem.button else { return }
        let value = viewModel.statusValue
        let shouldShowValue = settings.showValueInMenuBar && value != nil
        statusItem.length = shouldShowValue ? NSStatusItem.variableLength : NSStatusItem.squareLength
        StatusItemIconProvider.configure(
            button: button,
            category: viewModel.statusCategory,
            value: value,
            showValue: settings.showValueInMenuBar,
            city: viewModel.statusCityName ?? settings.selectedCity?.name
        )
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            togglePopover()
            return
        }
        switch event.type {
        case .rightMouseUp:
            showContextMenu()
        default:
            togglePopover()
        }
    }

    func showPopover() {
        guard let button = statusItem.button, !popover.isShown else {
            if !popover.isShown { NSApp.activate(ignoringOtherApps: true) }
            return
        }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        installEventMonitor()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
            removeEventMonitor()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            installEventMonitor()
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: L10n.MenuBar.refresh,
                     action: #selector(menuRefresh),
                     keyEquivalent: "r").target = self
        menu.addItem(withTitle: L10n.MenuBar.settingsEllipsis,
                     action: #selector(menuSettings),
                     keyEquivalent: ",").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: L10n.MenuBar.quitApp,
                     action: #selector(NSApplication.terminate(_:)),
                     keyEquivalent: "q")
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func menuRefresh() { viewModel.refresh() }
    @objc private func menuSettings() { openSettings() }

    private func openSettings() {
        if popover.isShown { popover.performClose(nil) }
        openSettingsAction()
    }

    private func installEventMonitor() {
        guard eventMonitor == nil else { return }
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in self?.popover.performClose(nil) }
        }
    }

    private func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
}
