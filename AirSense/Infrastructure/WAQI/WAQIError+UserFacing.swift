// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

extension WAQIError {
    var userFacingMessage: String {
        switch self {
        case .missingToken:        return L10n.Network.waqiMissingToken
        case .invalidToken:        return L10n.Network.waqiInvalidToken
        case .unknownStation:      return L10n.Network.waqiUnknownStation
        case .rateLimited:         return L10n.Network.waqiRateLimited
        case .transport:           return L10n.Network.waqiTransport
        case .decoding:            return L10n.Network.waqiDecoding
        case .upstream(let msg):   return L10n.Network.waqiUpstream(msg)
        }
    }
}
