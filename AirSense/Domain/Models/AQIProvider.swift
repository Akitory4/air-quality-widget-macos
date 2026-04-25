// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum AQIProvider: String, Codable, CaseIterable, Identifiable, Sendable {
    case openMeteo
    case waqi

    var id: String { rawValue }

    var supportsEuropeanAQI: Bool {
        switch self {
        case .openMeteo: return true
        case .waqi:     return false
        }
    }

    var requiresToken: Bool {
        switch self {
        case .openMeteo: return false
        case .waqi:     return true
        }
    }
}
