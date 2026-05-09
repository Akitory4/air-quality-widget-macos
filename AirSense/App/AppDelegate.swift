// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import WidgetKit

enum LaunchPresentationDestination: Equatable {
    case onboarding
    case settings
    case none
}

enum LaunchPresentationPolicy {
    static func destination(
        hasCompletedOnboarding: Bool,
        isDebugBuild: Bool = isDebugBuildConfiguration
    ) -> LaunchPresentationDestination {
        if !hasCompletedOnboarding {
            return .onboarding
        }
        return isDebugBuild ? .settings : .none
    }

    static var isDebugBuildConfiguration: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()

    let settings = SettingsStore()
    lazy var dependencies = AppDependencies.live(settings: settings)
    private(set) lazy var viewModel = AirQualityViewModel(
        service: dependencies.airQualityService,
        cache: dependencies.cache,
        settings: settings
    )
    private(set) lazy var citySearch = CitySearchViewModel(
        geocoder: dependencies.geocodingService,
        locationService: dependencies.locationService
    )
    private(set) lazy var appUpdate = AppUpdateController()
    private var menuBar: MenuBarController?
    private var onboardingWindowController: OnboardingWindowController?
    private var settingsWindowController: SettingsWindowController?
    private var scheduler: RefreshScheduler?
    private var isObservingSettings = true

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        terminateOtherRunningInstances()
        applyAppearance()
        menuBar = MenuBarController(
            viewModel: viewModel,
            settings: settings,
            appUpdate: appUpdate,
            openSettings: { [weak self] in
                self?.presentSettingsWindow()
            }
        )
        scheduler = RefreshScheduler(viewModel: viewModel, settings: settings)
        scheduler?.start()
        observeSettings()
        observeAppearance()
        viewModel.bootstrap()
        appUpdate.start()
        presentInitialUIIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        isObservingSettings = false
        scheduler?.stop()
        appUpdate.stop()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where url.scheme == "airsense" {
            handle(airsenseURL: url)
        }
    }

    private func handle(airsenseURL url: URL) {
        NSApp.activate(ignoringOtherApps: true)
        switch url.host {
        case "settings":
            presentSettingsWindow()
        case "popover":
            menuBar?.showPopover()
        default:
            menuBar?.showPopover()
        }
    }

    private func observeSettings() {
        guard isObservingSettings else { return }
        withObservationTracking {
            _ = settings.selectedCity
            _ = settings.aqiStandard
            _ = settings.refreshInterval
            _ = settings.provider
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, self.isObservingSettings else { return }
                self.scheduler?.reschedule()
                self.viewModel.refresh()
                self.observeSettings()
            }
        }
    }

    private func observeAppearance() {
        guard isObservingSettings else { return }
        withObservationTracking {
            _ = settings.appearance
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, self.isObservingSettings else { return }
                self.applyAppearance()
                WidgetCenter.shared.reloadAllTimelines()
                self.observeAppearance()
            }
        }
    }

    private func applyAppearance() {
        NSApp.appearance = settings.appearance.nsAppearance
    }

    private func presentInitialUIIfNeeded() {
        switch LaunchPresentationPolicy.destination(hasCompletedOnboarding: settings.hasCompletedOnboarding) {
        case .onboarding:
            openOnboardingIfNeeded()
        case .settings:
            presentSettingsWindow()
        case .none:
            break
        }
    }

    private func openOnboardingIfNeeded() {
        guard onboardingWindowController == nil else {
            onboardingWindowController?.present()
            return
        }
        onboardingWindowController = OnboardingWindowController(settings: settings) { [weak self] in
            self?.onboardingWindowController = nil
        }
        onboardingWindowController?.present()
    }

    private func presentSettingsWindow() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(
                settings: settings,
                viewModel: viewModel,
                citySearch: citySearch,
                tokenStore: dependencies.tokenStore,
                waqiService: dependencies.waqiService,
                onClose: { [weak self] in
                    self?.settingsWindowController = nil
                }
            )
        }
        settingsWindowController?.present()
    }

    private func terminateOtherRunningInstances() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        let currentProcessIdentifier = ProcessInfo.processInfo.processIdentifier
        for application in NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            where application.processIdentifier != currentProcessIdentifier {
            application.terminate()
        }
    }
}
