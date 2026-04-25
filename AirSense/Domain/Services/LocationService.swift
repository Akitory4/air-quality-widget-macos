// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

@MainActor
protocol LocationService: AnyObject {
    func currentLocation() async throws -> Coordinate
}

enum LocationServiceError: LocalizedError, Equatable, Sendable {
    case servicesDisabled
    case denied
    case restricted
    case requestInProgress
    case locationUnavailable
    case unknownAuthorization

    var errorDescription: String? {
        switch self {
        case .servicesDisabled:
            return L10n.Location.servicesDisabled
        case .denied:
            return L10n.Location.denied
        case .restricted:
            return L10n.Location.restricted
        case .requestInProgress:
            return L10n.Location.requestInProgress
        case .locationUnavailable:
            return L10n.Location.locationUnavailable
        case .unknownAuthorization:
            return L10n.Location.unknownAuthorization
        }
    }
}
