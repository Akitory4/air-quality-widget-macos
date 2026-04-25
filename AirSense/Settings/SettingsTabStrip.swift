// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case dataSource
    case about

    var id: Self { self }

    var label: String {
        switch self {
        case .general:    return L10n.Settings.generalTab
        case .dataSource: return L10n.Settings.dataSourceTab
        case .about:      return L10n.Settings.aboutTab
        }
    }

    var systemImage: String {
        switch self {
        case .general:    return "gearshape"
        case .dataSource: return "cylinder.split.1x2"
        case .about:      return "info.circle"
        }
    }
}

struct SettingsTabStrip: View {
    @Binding var selection: SettingsTab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                ForEach(SettingsTab.allCases) { tab in
                    TabButton(tab: tab, isSelected: selection == tab) {
                        selection = tab
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            Divider()
        }
        .background(.regularMaterial)
    }
}

private struct TabButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                Text(tab.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected ? Color.primary.opacity(0.10) : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}
