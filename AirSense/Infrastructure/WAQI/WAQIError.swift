// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum WAQIError: Error, Equatable {
    case missingToken
    case invalidToken
    case unknownStation
    case rateLimited
    case transport(String)
    case decoding(String)
    case upstream(String)
}
