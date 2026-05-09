// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

struct AppUpdateInfo: Equatable, Sendable {
    let version: String
    let displayVersion: String
    let downloadURL: URL?
}

enum AppUpdatePhase: Equatable {
    case idle
    case unavailable
    case checking
    case available
    case downloading(progress: Double?)
    case extracting(progress: Double?)
    case installing
    case failed(String)

    var isBusy: Bool {
        switch self {
        case .checking, .downloading, .extracting, .installing:
            return true
        case .idle, .unavailable, .available, .failed:
            return false
        }
    }

    var keepsUpdateButtonVisible: Bool {
        switch self {
        case .downloading, .extracting, .installing:
            return true
        case .idle, .unavailable, .checking, .available, .failed:
            return false
        }
    }
}

struct AppUpdateButtonState: Equatable {
    let isVisible: Bool
    let title: String
    let accessibilityLabel: String
    let isDisabled: Bool

    static let hidden = AppUpdateButtonState(
        isVisible: false,
        title: "",
        accessibilityLabel: "",
        isDisabled: true
    )
}
