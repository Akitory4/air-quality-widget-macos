// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class AirSenseTests: XCTestCase {
    func test_appBundleLoads() {
        let bundle = Bundle(for: AppDelegate.self)
        XCTAssertNotNil(bundle.bundleIdentifier)
    }

    func test_launchPresentation_showsOnboardingWhenNotCompleted() {
        let destination = LaunchPresentationPolicy.destination(
            hasCompletedOnboarding: false,
            isDebugBuild: false
        )

        XCTAssertEqual(destination, .onboarding)
    }

    func test_launchPresentation_showsSettingsForDebugLaunchAfterOnboarding() {
        let destination = LaunchPresentationPolicy.destination(
            hasCompletedOnboarding: true,
            isDebugBuild: true
        )

        XCTAssertEqual(destination, .settings)
    }

    func test_launchPresentation_staysMenuBarOnlyForReleaseLaunchAfterOnboarding() {
        let destination = LaunchPresentationPolicy.destination(
            hasCompletedOnboarding: true,
            isDebugBuild: false
        )

        XCTAssertEqual(destination, .none)
    }
}
