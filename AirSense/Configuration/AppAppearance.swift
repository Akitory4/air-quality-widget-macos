// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable, Sendable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

enum SharedAppearanceStore {
    static func load() -> AppAppearance {
        guard let data = try? Data(contentsOf: SharedStorage.appearanceURL()),
              let rawValue = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              let appearance = AppAppearance(rawValue: rawValue) else {
            return .system
        }
        return appearance
    }

    static func save(_ appearance: AppAppearance, fileManager: FileManager = .default) {
        let directory = SharedStorage.containerDirectory()
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = Data(appearance.rawValue.utf8)
        try? data.write(to: SharedStorage.appearanceURL(), options: .atomic)
    }
}
