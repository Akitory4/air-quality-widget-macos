// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

extension View {
    @ViewBuilder
    func widgetColorScheme(_ colorScheme: ColorScheme?) -> some View {
        if let colorScheme {
            environment(\.colorScheme, colorScheme)
        } else {
            self
        }
    }
}

struct WidgetBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    let tint: Color?

    var body: some View {
        ZStack {
            baseColor
            if let tint {
                tint.opacity(colorScheme == .dark ? 0.08 : 0.10)
            }
        }
    }

    private var baseColor: Color {
        colorScheme == .dark ? Color(nsColor: .windowBackgroundColor) : Color(hex: 0xF6F6F6)
    }
}
