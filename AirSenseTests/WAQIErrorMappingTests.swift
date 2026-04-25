// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class WAQIErrorMappingTests: XCTestCase {

    // MARK: - Envelope-level classification

    func test_classify_invalidKey_mapsToInvalidToken() {
        let err = WAQIAirQualityService.classify(errorMessage: "Invalid key", envelopeStatus: "error")
        XCTAssertEqual(err, .invalidToken)
    }

    func test_classify_wrongApiKey_variant_mapsToInvalidToken() {
        let err = WAQIAirQualityService.classify(errorMessage: "Wrong API key", envelopeStatus: "error")
        XCTAssertEqual(err, .invalidToken)
    }

    func test_classify_unknownStation_mapsToUnknownStation() {
        let err = WAQIAirQualityService.classify(errorMessage: "Unknown station", envelopeStatus: "error")
        XCTAssertEqual(err, .unknownStation)
    }

    func test_classify_noData_mapsToUnknownStation() {
        let err = WAQIAirQualityService.classify(errorMessage: "no data", envelopeStatus: "error")
        XCTAssertEqual(err, .unknownStation)
    }

    func test_classify_overQuota_mapsToRateLimited() {
        let err = WAQIAirQualityService.classify(errorMessage: "Over quota", envelopeStatus: "error")
        XCTAssertEqual(err, .rateLimited)
    }

    func test_classify_unknownMessage_fallsBackToUpstream() {
        let err = WAQIAirQualityService.classify(errorMessage: "Kaboom", envelopeStatus: "error")
        XCTAssertEqual(err, .upstream("Kaboom"))
    }

    // MARK: - HTTP-level translation

    func test_translate_badStatus429_mapsToRateLimited() {
        XCTAssertEqual(WAQIAirQualityService.translate(httpError: .badStatus(429)), .rateLimited)
    }

    func test_translate_badStatus500_mapsToUpstream() {
        XCTAssertEqual(WAQIAirQualityService.translate(httpError: .badStatus(500)), .upstream("HTTP 500"))
    }

    func test_translate_transport_mapsToTransport() {
        XCTAssertEqual(
            WAQIAirQualityService.translate(httpError: .transport("offline")),
            .transport("offline")
        )
    }

    func test_translate_decoding_mapsToDecoding() {
        XCTAssertEqual(
            WAQIAirQualityService.translate(httpError: .decoding("bad JSON")),
            .decoding("bad JSON")
        )
    }

    // MARK: - User-facing copy

    func test_userFacingMessage_coversAllCases() {
        XCTAssertFalse(WAQIError.missingToken.userFacingMessage.isEmpty)
        XCTAssertFalse(WAQIError.invalidToken.userFacingMessage.isEmpty)
        XCTAssertFalse(WAQIError.unknownStation.userFacingMessage.isEmpty)
        XCTAssertFalse(WAQIError.rateLimited.userFacingMessage.isEmpty)
        XCTAssertFalse(WAQIError.transport("x").userFacingMessage.isEmpty)
        XCTAssertFalse(WAQIError.decoding("x").userFacingMessage.isEmpty)
        XCTAssertTrue(WAQIError.upstream("boom").userFacingMessage.contains("boom"))
    }

    func test_errorExtension_bridgesWAQIError() {
        let err: Error = WAQIError.invalidToken
        XCTAssertEqual(err.userFacingMessage, L10n.Network.waqiInvalidToken)
    }
}
