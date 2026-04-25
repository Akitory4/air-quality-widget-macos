// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct SettingsFooter: View {
    @Bindable var settings: SettingsStore
    let onClose: () -> Void

    private var versionString: String {
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "—"
        return "v\(version) · \(providerLabel)"
    }

    private var providerLabel: String {
        switch settings.provider {
        case .openMeteo: return "Open-Meteo"
        case .waqi:      return "WAQI"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text(versionString)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(L10n.Settings.close) {
                    onClose()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .background(.regularMaterial)
    }
}
