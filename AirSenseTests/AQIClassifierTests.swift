// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class AQIClassifierTests: XCTestCase {
    func test_european_boundaries() {
        XCTAssertEqual(AQIClassifier.category(for: 1, standard: .european), .good)
        XCTAssertEqual(AQIClassifier.category(for: 2, standard: .european), .fair)
        XCTAssertEqual(AQIClassifier.category(for: 3, standard: .european), .moderate)
        XCTAssertEqual(AQIClassifier.category(for: 4, standard: .european), .poor)
        XCTAssertEqual(AQIClassifier.category(for: 5, standard: .european), .veryPoor)
        XCTAssertEqual(AQIClassifier.category(for: 6, standard: .european), .extremelyPoor)
        XCTAssertEqual(AQIClassifier.category(for: 99, standard: .european), .extremelyPoor)
    }

    func test_usEpa_boundaries() {
        XCTAssertEqual(AQIClassifier.category(for: 0, standard: .usEpa), .good)
        XCTAssertEqual(AQIClassifier.category(for: 50, standard: .usEpa), .good)
        XCTAssertEqual(AQIClassifier.category(for: 51, standard: .usEpa), .fair)
        XCTAssertEqual(AQIClassifier.category(for: 100, standard: .usEpa), .fair)
        XCTAssertEqual(AQIClassifier.category(for: 150, standard: .usEpa), .moderate)
        XCTAssertEqual(AQIClassifier.category(for: 200, standard: .usEpa), .poor)
        XCTAssertEqual(AQIClassifier.category(for: 300, standard: .usEpa), .veryPoor)
        XCTAssertEqual(AQIClassifier.category(for: 301, standard: .usEpa), .extremelyPoor)
        XCTAssertEqual(AQIClassifier.category(for: 500, standard: .usEpa), .extremelyPoor)
    }
}
