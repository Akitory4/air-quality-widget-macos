// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct OnboardingView: View {
    @Bindable var settings: SettingsStore
    let onComplete: () -> Void
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        .init(
            title: L10n.Onboarding.pageMenuBarTitle,
            message: L10n.Onboarding.pageMenuBarMessage,
            systemImage: "menubar.rectangle",
            accent: Color(hex: 0x0A84FF)
        ),
        .init(
            title: L10n.Onboarding.pageLocationTitle,
            message: L10n.Onboarding.pageLocationMessage,
            systemImage: "location.viewfinder",
            accent: Color(hex: 0x34C759)
        ),
        .init(
            title: L10n.Onboarding.pageCustomizeTitle,
            message: L10n.Onboarding.pageCustomizeMessage,
            systemImage: "slider.horizontal.3",
            accent: Color(hex: 0xFF9F0A)
        )
    ]

    private var isLastPage: Bool {
        currentPage == pages.indices.last
    }

    init(settings: SettingsStore, onComplete: @escaping () -> Void = {}) {
        self.settings = settings
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Onboarding.welcomeEyebrow)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.8)
                    Text(L10n.Onboarding.welcomeTitle)
                        .font(.system(size: 30, weight: .bold))
                    Text(L10n.Onboarding.welcomeMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 420, alignment: .leading)
                }

                Spacer(minLength: 20)

                if !isLastPage {
                    Button(L10n.Onboarding.skip) {
                        completeOnboarding()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 52)
            .padding(.bottom, 18)

            OnboardingPageCard(
                page: pages[currentPage],
                stepLabel: L10n.Onboarding.step(currentPage + 1, total: pages.count),
                onSwipeForward: goToNextPage,
                onSwipeBackward: goToPreviousPage
            )
            .id(currentPage)
            .frame(height: 220)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)))
            .animation(.easeInOut(duration: 0.22), value: currentPage)

            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Button {
                        goToPage(index)
                    } label: {
                        Capsule()
                            .fill(index == currentPage ? pages[index].accent : Color.primary.opacity(0.12))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)

            Text(L10n.Onboarding.footer)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 14)

            HStack {
                Button(L10n.Onboarding.back) {
                    goToPreviousPage()
                }
                .disabled(currentPage == 0)

                Spacer()

                Button(isLastPage ? L10n.Onboarding.finish : L10n.Onboarding.next) {
                    if isLastPage {
                        completeOnboarding()
                    } else {
                        goToNextPage()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor).opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        onComplete()
    }

    private func goToPreviousPage() {
        guard currentPage > 0 else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            currentPage -= 1
        }
    }

    private func goToNextPage() {
        guard currentPage < pages.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            currentPage += 1
        }
    }

    private func goToPage(_ page: Int) {
        guard pages.indices.contains(page), page != currentPage else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            currentPage = page
        }
    }
}

private struct OnboardingPage: Equatable {
    let title: String
    let message: String
    let systemImage: String
    let accent: Color
}

private struct OnboardingPageCard: View {
    private enum Metrics {
        static let swipeThreshold: CGFloat = 50
    }

    let page: OnboardingPage
    let stepLabel: String
    let onSwipeForward: () -> Void
    let onSwipeBackward: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text(stepLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.8)

                Text(page.title)
                    .font(.system(size: 24, weight: .semibold))

                Text(page.message)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [page.accent.opacity(0.22), page.accent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(page.accent.opacity(0.18), lineWidth: 1)
                    }

                Image(systemName: page.systemImage)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(page.accent)
            }
            .frame(width: 168, height: 168)
            .accessibilityHidden(true)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width <= -Metrics.swipeThreshold {
                        onSwipeForward()
                    } else if value.translation.width >= Metrics.swipeThreshold {
                        onSwipeBackward()
                    }
                }
        )
    }
}
