// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import XCTest
@testable import AirSense

final class InMemoryTokenStoreTests: XCTestCase {
    func test_getReturnsNil_whenEmpty() throws {
        let store = InMemoryTokenStore()
        XCTAssertNil(try store.get())
    }

    func test_setThenGet_returnsStoredToken() throws {
        let store = InMemoryTokenStore()
        try store.set("abc123")
        XCTAssertEqual(try store.get(), "abc123")
    }

    func test_setOverwritesPreviousValue() throws {
        let store = InMemoryTokenStore(initial: "old")
        try store.set("new")
        XCTAssertEqual(try store.get(), "new")
    }

    func test_delete_clearsToken() throws {
        let store = InMemoryTokenStore(initial: "abc")
        try store.delete()
        XCTAssertNil(try store.get())
    }

    func test_delete_whenEmpty_isNoOp() throws {
        let store = InMemoryTokenStore()
        XCTAssertNoThrow(try store.delete())
    }
}

final class KeychainTokenStoreTests: XCTestCase {
    private var store: KeychainTokenStore!
    private var service: String!

    override func setUp() {
        super.setUp()
        service = "\(AppConfiguration.BundleIdentifiers.tests).\(UUID().uuidString)"
        store = KeychainTokenStore(service: service, account: AppConfiguration.Keychain.waqiTokenAccount)
    }

    override func tearDown() {
        try? store.delete()
        store = nil
        super.tearDown()
    }

    func test_roundTrip_storeThenRead() throws {
        try store.set("token-abc")
        XCTAssertEqual(try store.get(), "token-abc")
    }

    func test_update_overwritesPrevious() throws {
        try store.set("first")
        try store.set("second")
        XCTAssertEqual(try store.get(), "second")
    }

    func test_delete_removesItem() throws {
        try store.set("soon-gone")
        try store.delete()
        XCTAssertNil(try store.get())
    }
}
