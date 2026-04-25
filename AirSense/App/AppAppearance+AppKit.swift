// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit

extension AppAppearance {
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light:  return NSAppearance(named: .aqua)
        case .dark:   return NSAppearance(named: .darkAqua)
        }
    }
}
