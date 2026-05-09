// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Combine
import Foundation
import Sparkle

@MainActor
final class AppUpdateController: NSObject, ObservableObject {
    @Published private(set) var phase: AppUpdatePhase = .idle
    @Published private(set) var availableUpdate: AppUpdateInfo?
    @Published private(set) var errorMessage: String?

    private let bundle: Bundle
    private var updater: SPUUpdater?
    private var probeTimer: Timer?
    private var expectedDownloadLength: UInt64?
    private var receivedDownloadLength: UInt64 = 0
    private var installRequested = false

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        super.init()
    }

    deinit {
        MainActor.assumeIsolated {
            probeTimer?.invalidate()
        }
    }

    var buttonState: AppUpdateButtonState {
        guard availableUpdate != nil || phase.keepsUpdateButtonVisible else {
            return .hidden
        }

        return AppUpdateButtonState(
            isVisible: true,
            title: buttonTitle,
            accessibilityLabel: accessibilityLabel,
            isDisabled: phase.isBusy
        )
    }

    func start() {
        guard updater == nil else { return }
        guard Self.hasUsableSparkleConfiguration(in: bundle) else {
            phase = .unavailable
            return
        }

        let updater = SPUUpdater(
            hostBundle: bundle,
            applicationBundle: bundle,
            userDriver: self,
            delegate: self
        )
        self.updater = updater

        do {
            try updater.start()
            updater.clearFeedURLFromUserDefaults()
            checkForUpdateInformation()
            scheduleBackgroundProbes()
        } catch {
            phase = .unavailable
            errorMessage = L10n.Update.configurationFailed(error.localizedDescription)
        }
    }

    func stop() {
        probeTimer?.invalidate()
        probeTimer = nil
    }

    func installUpdate() {
        guard !phase.isBusy else { return }
        guard let updater else {
            errorMessage = L10n.Update.notConfigured
            return
        }

        errorMessage = nil
        installRequested = true
        phase = .checking
        updater.checkForUpdates()
    }

    private var buttonTitle: String {
        switch phase {
        case .downloading(let progress):
            guard let progress else { return L10n.Update.progressPending }
            return L10n.Update.percent(Int((progress * 100).rounded()))
        case .extracting, .installing, .checking:
            return L10n.Update.progressPending
        case .idle, .unavailable, .available, .failed:
            return L10n.Update.button
        }
    }

    private var accessibilityLabel: String {
        if let availableUpdate {
            return L10n.Update.updateToVersion(availableUpdate.displayVersion)
        }
        return L10n.Update.button
    }

    private func checkForUpdateInformation() {
        guard let updater, !updater.sessionInProgress else { return }
        errorMessage = nil
        if availableUpdate == nil {
            phase = .checking
        }
        updater.checkForUpdateInformation()
    }

    private func scheduleBackgroundProbes() {
        probeTimer?.invalidate()
        probeTimer = Timer.scheduledTimer(withTimeInterval: 6 * 60 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkForUpdateInformation()
            }
        }
    }

    private func updateAvailable(from item: SUAppcastItem) {
        availableUpdate = AppUpdateInfo(
            version: item.versionString,
            displayVersion: item.displayVersionString,
            downloadURL: item.fileURL
        )
        if !phase.isBusy {
            phase = .available
        }
    }

    private func clearAvailableUpdate() {
        availableUpdate = nil
        if !phase.isBusy {
            phase = .idle
        }
    }

    private func finishWithoutUpdate() {
        installRequested = false
        resetProgressCounters()
        availableUpdate = nil
        phase = .idle
        errorMessage = nil
    }

    private func resetProgressCounters() {
        expectedDownloadLength = nil
        receivedDownloadLength = 0
    }

    private func fail(_ message: String) {
        installRequested = false
        resetProgressCounters()
        phase = .failed(message)
        errorMessage = message
    }

    nonisolated static func isNoUpdateError(_ error: any Error) -> Bool {
        let nsError = error as NSError
        guard nsError.code == 1001 else { return false }

        return nsError.domain == "SUSparkleErrorDomain"
            || nsError.localizedDescription.localizedCaseInsensitiveContains("up to date")
            || nsError.localizedDescription.localizedCaseInsensitiveContains("no update")
    }

    private static func hasUsableSparkleConfiguration(in bundle: Bundle) -> Bool {
        guard
            let feedURL = bundle.object(forInfoDictionaryKey: "SUFeedURL") as? String,
            let publicKey = bundle.object(forInfoDictionaryKey: "SUPublicEDKey") as? String
        else {
            return false
        }

        let trimmedFeedURL = feedURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPublicKey = publicKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedFeedURL.isEmpty
            && !trimmedFeedURL.contains("$(")
            && URL(string: trimmedFeedURL) != nil
            && !trimmedPublicKey.isEmpty
            && !trimmedPublicKey.contains("$(")
    }
}

extension AppUpdateController: SPUUpdaterDelegate {
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        updateAvailable(from: item)
    }

    func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: any Error) {
        finishWithoutUpdate()
    }

    func updater(_ updater: SPUUpdater, didAbortWithError error: any Error) {
        guard !Self.isNoUpdateError(error) else {
            finishWithoutUpdate()
            return
        }

        fail(L10n.Update.failed(error.localizedDescription))
    }

    func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: any Error) {
        guard !Self.isNoUpdateError(error) else {
            finishWithoutUpdate()
            return
        }

        fail(L10n.Update.failed(error.localizedDescription))
    }

    func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        phase = .extracting(progress: nil)
    }

    func updater(_ updater: SPUUpdater, willExtractUpdate item: SUAppcastItem) {
        phase = .extracting(progress: nil)
    }

    func updater(_ updater: SPUUpdater, didExtractUpdate item: SUAppcastItem) {
        phase = .installing
    }

    func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
        phase = .installing
    }

    func updaterShouldRelaunchApplication(_ updater: SPUUpdater) -> Bool {
        true
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        phase = .installing
    }

    func updater(
        _ updater: SPUUpdater,
        willInstallUpdateOnQuit item: SUAppcastItem,
        immediateInstallationBlock immediateInstallHandler: @escaping () -> Void
    ) -> Bool {
        phase = .installing
        immediateInstallHandler()
        return true
    }
}

extension AppUpdateController: SPUUserDriver {
    func show(_ request: SPUUpdatePermissionRequest) async -> SUUpdatePermissionResponse {
        SUUpdatePermissionResponse(automaticUpdateChecks: false, sendSystemProfile: false)
    }

    func showUserInitiatedUpdateCheck(cancellation: @escaping () -> Void) {
        phase = .checking
    }

    func showUpdateFound(with appcastItem: SUAppcastItem, state: SPUUserUpdateState) async -> SPUUserUpdateChoice {
        updateAvailable(from: appcastItem)

        guard !appcastItem.isInformationOnlyUpdate else {
            fail(L10n.Update.informationOnly)
            return .dismiss
        }

        guard installRequested || state.userInitiated else {
            return .dismiss
        }

        installRequested = false
        resetProgressCounters()
        phase = .downloading(progress: nil)
        return .install
    }

    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {}

    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: any Error) {}

    func showUpdateNotFoundWithError(_ error: any Error) async {
        finishWithoutUpdate()
    }

    func showUpdaterError(_ error: any Error) async {
        guard !Self.isNoUpdateError(error) else {
            finishWithoutUpdate()
            return
        }

        fail(L10n.Update.failed(error.localizedDescription))
    }

    func showDownloadInitiated(cancellation: @escaping () -> Void) {
        resetProgressCounters()
        phase = .downloading(progress: nil)
    }

    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        self.expectedDownloadLength = expectedContentLength > 0 ? expectedContentLength : nil
        receivedDownloadLength = 0
        phase = .downloading(progress: nil)
    }

    func showDownloadDidReceiveData(ofLength length: UInt64) {
        receivedDownloadLength += length
        guard let expectedDownloadLength, expectedDownloadLength > 0 else {
            phase = .downloading(progress: nil)
            return
        }

        let progress = min(1, Double(receivedDownloadLength) / Double(expectedDownloadLength))
        phase = .downloading(progress: progress)
    }

    func showDownloadDidStartExtractingUpdate() {
        phase = .extracting(progress: nil)
    }

    func showExtractionReceivedProgress(_ progress: Double) {
        phase = .extracting(progress: min(max(progress, 0), 1))
    }

    func showReadyToInstallAndRelaunch() async -> SPUUserUpdateChoice {
        phase = .installing
        return .install
    }

    func showInstallingUpdate(
        withApplicationTerminated applicationTerminated: Bool,
        retryTerminatingApplication: @escaping () -> Void
    ) {
        phase = .installing
    }

    func showUpdateInstalledAndRelaunched(_ relaunched: Bool) async {
        phase = .installing
    }

    func dismissUpdateInstallation() {
        installRequested = false
        resetProgressCounters()
        if availableUpdate != nil {
            phase = .available
        } else {
            phase = .idle
        }
    }

    func showUpdateInFocus() {}
}
