// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

final class InMemoryTokenStore: TokenStore, @unchecked Sendable {
    private let lock = NSLock()
    private var storedToken: String?

    init(initial: String? = nil) {
        self.storedToken = initial
    }

    func get() throws -> String? {
        lock.lock(); defer { lock.unlock() }
        return storedToken
    }

    func set(_ token: String) throws {
        lock.lock(); defer { lock.unlock() }
        storedToken = token
    }

    func delete() throws {
        lock.lock(); defer { lock.unlock() }
        storedToken = nil
    }
}
