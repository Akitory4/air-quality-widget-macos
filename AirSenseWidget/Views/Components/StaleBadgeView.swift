// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct StaleBadgeView: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(WidgetPalette.staleText)
            Text("STALE")
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.2)
                .foregroundStyle(WidgetPalette.staleText)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 1)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(WidgetPalette.staleAccent.opacity(0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(WidgetPalette.staleAccent.opacity(0.4), lineWidth: 0.5)
                )
        )
    }
}
