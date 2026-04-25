// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

@preconcurrency import CoreLocation
import Foundation

@MainActor
final class CoreLocationService: NSObject, LocationService {
    private let manager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    private var locationContinuation: CheckedContinuation<Coordinate, Error>?

    private static let requestTimeout: Double = 15

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        _ = manager.authorizationStatus
    }

    func currentLocation() async throws -> Coordinate {
        let enabled = await Task.detached { CLLocationManager.locationServicesEnabled() }.value
        guard enabled else {
            throw LocationServiceError.servicesDisabled
        }
        guard locationContinuation == nil, authorizationContinuation == nil else {
            throw LocationServiceError.requestInProgress
        }

        let timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.requestTimeout))
            guard !Task.isCancelled else { return }
            self?.cancelPending(with: LocationServiceError.locationUnavailable)
        }
        defer { timeoutTask.cancel() }

        try await ensureAuthorization()

        return try await withCheckedThrowingContinuation { [manager] continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    private func ensureAuthorization() async throws {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .notDetermined:
            guard authorizationContinuation == nil else {
                throw LocationServiceError.requestInProgress
            }
            try await withCheckedThrowingContinuation { [manager] continuation in
                authorizationContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        case .denied:
            throw LocationServiceError.denied
        case .restricted:
            throw LocationServiceError.restricted
        @unknown default:
            throw LocationServiceError.unknownAuthorization
        }
    }

    private func finishAuthorization(with result: Result<Void, Error>) {
        guard let authorizationContinuation else { return }
        self.authorizationContinuation = nil
        authorizationContinuation.resume(with: result)
    }

    private func finishLocation(with result: Result<Coordinate, Error>) {
        guard let locationContinuation else { return }
        self.locationContinuation = nil
        locationContinuation.resume(with: result)
    }

    private func cancelPending(with error: Error) {
        finishAuthorization(with: .failure(error))
        finishLocation(with: .failure(error))
    }

    private static func mapLocationError(_ error: Error) -> Error {
        guard let clError = error as? CLError else { return error }
        switch clError.code {
        case .denied:
            return LocationServiceError.denied
        case .network, .locationUnknown:
            return LocationServiceError.locationUnavailable
        default:
            return LocationServiceError.locationUnavailable
        }
    }
}

@MainActor
extension CoreLocationService: @preconcurrency CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            finishAuthorization(with: .success(()))
        case .denied:
            finishAuthorization(with: .failure(LocationServiceError.denied))
        case .restricted:
            finishAuthorization(with: .failure(LocationServiceError.restricted))
        case .notDetermined:
            break
        @unknown default:
            finishAuthorization(with: .failure(LocationServiceError.unknownAuthorization))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finishLocation(with: .failure(LocationServiceError.locationUnavailable))
            return
        }

        finishLocation(with: .success(
            Coordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        ))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocation(with: .failure(Self.mapLocationError(error)))
    }
}
