// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import ServiceManagement

enum LaunchAtLogin {
    private static let registrationFingerprintKey = "launchAtLoginRegistrationFingerprint"

    enum RegistrationError: LocalizedError {
        case requiresApproval
        case registrationDidNotEnable(status: String)

        var errorDescription: String? {
            switch self {
            case .requiresApproval:
                return "Allow AirSense in System Settings > General > Login Items."
            case .registrationDidNotEnable(let status):
                return "macOS reported login item status: \(status)."
            }
        }
    }

    static func setEnabled(_ enabled: Bool, defaults: UserDefaults = .standard) throws {
        if enabled {
            try ensureRegistered(defaults: defaults, refreshExistingRegistration: false)
        } else {
            try unregister(defaults: defaults)
        }
    }

    static func reconcile(enabledPreference: Bool, defaults: UserDefaults = .standard) throws {
        if enabledPreference {
            let fingerprint = registrationFingerprint()
            let shouldRefresh = defaults.string(forKey: registrationFingerprintKey) != fingerprint
            try ensureRegistered(defaults: defaults, refreshExistingRegistration: shouldRefresh)
        } else if SMAppService.mainApp.status == .enabled {
            try unregister(defaults: defaults)
        } else {
            defaults.removeObject(forKey: registrationFingerprintKey)
        }
    }

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    private static func ensureRegistered(
        defaults: UserDefaults,
        refreshExistingRegistration: Bool
    ) throws {
        let service = SMAppService.mainApp
        if refreshExistingRegistration, service.status == .enabled {
            try service.unregister()
        }

        switch service.status {
        case .enabled:
            defaults.set(registrationFingerprint(), forKey: registrationFingerprintKey)
        case .requiresApproval:
            throw RegistrationError.requiresApproval
        case .notRegistered, .notFound:
            try service.register()
            guard service.status == .enabled else {
                throw RegistrationError.registrationDidNotEnable(status: statusDescription)
            }
            defaults.set(registrationFingerprint(), forKey: registrationFingerprintKey)
        @unknown default:
            try service.register()
            guard service.status == .enabled else {
                throw RegistrationError.registrationDidNotEnable(status: statusDescription)
            }
            defaults.set(registrationFingerprint(), forKey: registrationFingerprintKey)
        }
    }

    private static func unregister(defaults: UserDefaults) throws {
        let service = SMAppService.mainApp
        if service.status == .enabled || service.status == .requiresApproval {
            try service.unregister()
        }
        defaults.removeObject(forKey: registrationFingerprintKey)
    }

    private static var statusDescription: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "enabled"
        case .notRegistered:
            return "not registered"
        case .notFound:
            return "not found"
        case .requiresApproval:
            return "requires approval"
        @unknown default:
            return "unknown"
        }
    }

    private static func registrationFingerprint(bundle: Bundle = .main) -> String {
        let identifier = bundle.bundleIdentifier ?? "unknown"
        let version = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let shortVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        return "\(identifier)|\(shortVersion)|\(version)|\(bundle.bundleURL.standardizedFileURL.path)"
    }
}
