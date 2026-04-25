// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct WidgetShell<Content: View>: View {
    let tint: Color?
    let padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(tint: Color?, padding: CGFloat = 14, @ViewBuilder content: @escaping () -> Content) {
        self.tint = tint
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UpdatedStamp: View {
    enum Tone { case subtle, strong }
    let date: Date
    var tone: Tone = .subtle

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
            Text(WidgetRelativeTime.short(date))
                .font(.system(size: 10))
                .monospacedDigit()
                .foregroundStyle(tone == .subtle ? Color.secondary : Color.primary)
                .lineLimit(1)
        }
    }
}

enum WidgetRelativeTime {
    static func short(_ date: Date, now: Date = Date()) -> String {
        let delta = date.timeIntervalSince(now)
        if delta > -60 && delta < 60 { return "just now" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: now)
    }
}

struct StaleStamp: View {
    let ageMinutes: Int

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.system(size: 9))
                .foregroundStyle(WidgetPalette.staleText)
            Text("\(ageMinutes) min ago")
                .font(.system(size: 10, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(WidgetPalette.staleText)
                .lineLimit(1)
        }
    }
}

struct CtaRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(WidgetPalette.cta)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WidgetPalette.cta)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct RedactedBar: View {
    let width: CGFloat
    let height: CGFloat
    var radius: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(Color.secondary.opacity(0.18))
            .frame(width: width, height: height)
    }
}
