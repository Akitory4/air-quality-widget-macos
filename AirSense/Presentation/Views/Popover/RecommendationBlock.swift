// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct RecommendationBlock: View {
    let category: AQICategory
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(category.color.opacity(0.92))
                Text(verbatim: "!")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 16, height: 16)
            .padding(.top, 1)

            Text(text)
                .font(.system(size: 11.5))
                .foregroundStyle(.primary.opacity(0.92))
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .padding(.leading, 2)
        .background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(category.color)
                .frame(width: 3)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8))
        }
        .padding(.horizontal, 14)
        .padding(.top, 2)
    }
}
