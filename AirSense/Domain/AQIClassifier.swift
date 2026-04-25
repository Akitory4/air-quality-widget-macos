// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum AQIClassifier {
    static func category(for value: Int, standard: AQIStandard) -> AQICategory {
        switch standard {
        case .european: return .forEuropean(value)
        case .usEpa:    return .forUSEPA(value)
        }
    }
}
