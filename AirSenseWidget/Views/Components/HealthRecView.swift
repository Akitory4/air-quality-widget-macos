// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct HealthRecView: View {
    let category: WidgetCategory
    let text: String
    var mutedForStale: Bool = false

    private var symbolName: String {
        category.value >= 4 ? "exclamationmark.triangle.fill" : "leaf.fill"
    }

    private var accentColor: Color {
        mutedForStale ? WidgetPalette.staleAccent : category.color
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbolName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(mutedForStale ? WidgetPalette.staleText : category.color)
            Text(text)
                .font(.system(size: 11.5))
                .lineSpacing(2)
                .foregroundStyle(mutedForStale ? Color.secondary : Color.primary.opacity(0.92))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(accentColor.opacity(0.10))
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 8, bottomLeadingRadius: 8,
                        bottomTrailingRadius: 0, topTrailingRadius: 0,
                        style: .continuous
                    )
                )
        }
    }
}
