// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct AQIBadgeView: View {
    enum Shape { case circle, squircle }

    let category: WidgetCategory
    let value: Int
    let size: CGFloat
    var shape: Shape = .circle

    private var cornerRadius: CGFloat {
        switch shape {
        case .circle:   return size / 2
        case .squircle: return size * 0.28
        }
    }

    private var numericFontSize: CGFloat {
        size > 60 ? size * 0.52 : size * 0.48
    }

    private var scaleHintFontSize: CGFloat { size * 0.14 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(category.color)
                .shadow(color: category.color.opacity(0.40), radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                        .blendMode(.plusLighter)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.7), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                )
                .frame(width: size, height: size)

            VStack(spacing: size * 0.04) {
                Text("\(value)")
                    .font(.system(size: numericFontSize, weight: .bold, design: .default))
                    .monospacedDigit()
                    .foregroundStyle(category.numericColor)
                    .tracking(-1)
                Text(category.scaleHintText)
                    .font(.system(size: scaleHintFontSize, weight: .bold))
                    .tracking(0.4)
                    .foregroundStyle(category.scaleHintColor)
            }
        }
        .frame(width: size, height: size)
    }
}
