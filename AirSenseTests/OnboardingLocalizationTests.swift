// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class OnboardingLocalizationTests: XCTestCase {
    func test_stepLabel_usesExpectedEnglishFallback() {
        XCTAssertEqual(L10n.Onboarding.step(2, total: 3), "Step 2 of 3")
    }

    func test_finishLabel_usesExpectedEnglishFallback() {
        XCTAssertEqual(L10n.Onboarding.finish, "Start Using AirSense")
    }
}
