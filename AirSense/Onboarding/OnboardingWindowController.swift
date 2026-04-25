// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import SwiftUI

@MainActor
final class OnboardingWindowController: NSWindowController, NSWindowDelegate {
    private enum Metrics {
        static let preferredContentSize = NSSize(width: 680, height: 560)
        static let screenInset: CGFloat = 40
    }

    private let onClose: () -> Void

    init(settings: SettingsStore, onClose: @escaping () -> Void) {
        self.onClose = onClose

        let hostingController = NSHostingController(rootView: OnboardingView(settings: settings))
        hostingController.sizingOptions = []
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(Metrics.preferredContentSize)
        window.contentMinSize = Metrics.preferredContentSize
        window.title = L10n.Onboarding.welcomeTitle
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true

        super.init(window: window)

        window.delegate = self
        hostingController.rootView = OnboardingView(settings: settings) { [weak self] in
            self?.close()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        fitWindowToVisibleScreen()
        window?.makeKeyAndOrderFront(nil)
        Task { @MainActor [weak self] in
            await Task.yield()
            self?.fitWindowToVisibleScreen()
        }
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }

    private func fitWindowToVisibleScreen() {
        guard let window else { return }

        let visibleFrame = window.screen?.visibleFrame
            ?? screenContainingMouseLocation()?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? NSScreen.screens.first?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 960, height: 640)

        let maxContentWidth = max(420, visibleFrame.width - (Metrics.screenInset * 2))
        let maxContentHeight = max(320, visibleFrame.height - (Metrics.screenInset * 2))
        let contentSize = NSSize(
            width: min(Metrics.preferredContentSize.width, maxContentWidth),
            height: min(Metrics.preferredContentSize.height, maxContentHeight)
        )

        let contentRect = NSRect(origin: .zero, size: contentSize)
        var frame = window.frameRect(forContentRect: contentRect)
        frame.origin.x = visibleFrame.midX - (frame.width / 2)
        frame.origin.y = visibleFrame.midY - (frame.height / 2)

        if frame.minX < visibleFrame.minX + Metrics.screenInset {
            frame.origin.x = visibleFrame.minX + Metrics.screenInset
        }
        if frame.maxX > visibleFrame.maxX - Metrics.screenInset {
            frame.origin.x = visibleFrame.maxX - Metrics.screenInset - frame.width
        }
        if frame.minY < visibleFrame.minY + Metrics.screenInset {
            frame.origin.y = visibleFrame.minY + Metrics.screenInset
        }
        if frame.maxY > visibleFrame.maxY - Metrics.screenInset {
            frame.origin.y = visibleFrame.maxY - Metrics.screenInset - frame.height
        }

        window.setFrame(frame.integral, display: false)
    }

    private func screenContainingMouseLocation() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
    }
}
