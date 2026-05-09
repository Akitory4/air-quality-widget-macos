// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class AppUpdateStateTests: XCTestCase {
    func test_idlePhase_isNotBusy() {
        XCTAssertFalse(AppUpdatePhase.idle.isBusy)
    }

    func test_downloadingPhase_isBusy() {
        XCTAssertTrue(AppUpdatePhase.downloading(progress: 0.5).isBusy)
    }

    func test_checkingPhase_doesNotKeepUpdateButtonVisibleByItself() {
        XCTAssertFalse(AppUpdatePhase.checking.keepsUpdateButtonVisible)
    }

    func test_installingPhase_keepsUpdateButtonVisible() {
        XCTAssertTrue(AppUpdatePhase.installing.keepsUpdateButtonVisible)
    }

    func test_hiddenButtonState_isNotVisibleAndDisabled() {
        XCTAssertFalse(AppUpdateButtonState.hidden.isVisible)
        XCTAssertTrue(AppUpdateButtonState.hidden.isDisabled)
    }

    func test_updateLocalization_usesExpectedEnglishFallbacks() {
        XCTAssertEqual(L10n.Update.button, "Update")
        XCTAssertEqual(L10n.Update.updateToVersion("0.2.0"), "Update to version 0.2.0")
        XCTAssertEqual(L10n.Update.percent(42), "42%")
    }
}
