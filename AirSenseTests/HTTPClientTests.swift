// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (Data, HTTPURLResponse))?

    // These are `class` (not `static`) because URLProtocol requires
    // them as overridable class methods — `static` would not satisfy
    // the superclass override contract. The static_over_final_class
    // rule can't distinguish the two, so we suppress per-line.
    // swiftlint:disable:next static_over_final_class
    override class func canInit(with request: URLRequest) -> Bool { true }
    // swiftlint:disable:next static_over_final_class
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}

final class HTTPClientTests: XCTestCase {
    private struct Payload: Decodable, Equatable { let foo: String }

    private func makeClient() -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSessionHTTPClient(session: URLSession(configuration: config))
    }

    override func tearDown() {
        MockURLProtocol.handler = nil
        super.tearDown()
    }

    func test_get_decodesPayload() async throws {
        let url = URL(string: "https://example.com/data")!
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.url, url)
            let data = #"{"foo":"bar"}"#.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        let payload = try await makeClient().get(url, as: Payload.self)
        XCTAssertEqual(payload, Payload(foo: "bar"))
    }

    func test_get_throwsBadStatus() async {
        let url = URL(string: "https://example.com/data")!
        MockURLProtocol.handler = { _ in
            (Data(), HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!)
        }
        do {
            _ = try await makeClient().get(url, as: Payload.self)
            XCTFail("Expected bad status error")
        } catch let error as HTTPError {
            XCTAssertEqual(error, .badStatus(500))
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }

    func test_get_throwsDecodingError() async {
        let url = URL(string: "https://example.com/data")!
        MockURLProtocol.handler = { _ in
            let data = "not-json".data(using: .utf8)!
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        do {
            _ = try await makeClient().get(url, as: Payload.self)
            XCTFail("Expected decoding error")
        } catch let HTTPError.decoding(message) {
            XCTAssertFalse(message.isEmpty)
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }
}
