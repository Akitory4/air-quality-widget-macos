// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

extension HTTPError {
    var userFacingMessage: String {
        switch self {
        case .invalidURL:          return L10n.Network.invalidRequestURL
        case .transport:           return L10n.Network.connectionError
        case .badStatus(let code): return L10n.Network.serviceStatus(code)
        case .decoding:            return L10n.Network.decodingError
        }
    }
}

extension Error {
    var userFacingMessage: String {
        if let httpError = self as? HTTPError {
            return httpError.userFacingMessage
        }
        if let waqiError = self as? WAQIError {
            return waqiError.userFacingMessage
        }
        return localizedDescription
    }
}
