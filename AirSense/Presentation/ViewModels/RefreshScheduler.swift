// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import Foundation

@MainActor
final class RefreshScheduler {
    private weak var viewModel: AirQualityViewModel?
    private let settings: SettingsStore
    private var timer: Timer?
    private var wakeObserver: NSObjectProtocol?

    init(viewModel: AirQualityViewModel, settings: SettingsStore) {
        self.viewModel = viewModel
        self.settings = settings
    }

    func start() {
        scheduleTimer()
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.viewModel?.refresh() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            self.wakeObserver = nil
        }
    }

    func reschedule() {
        scheduleTimer()
    }

    private func scheduleTimer() {
        timer?.invalidate()
        let interval = settings.refreshInterval.seconds
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.viewModel?.refresh() }
        }
        timer.tolerance = interval * 0.1
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    deinit {
        MainActor.assumeIsolated {
            timer?.invalidate()
            if let wakeObserver {
                NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            }
        }
    }
}
