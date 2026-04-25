// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

enum TokenStoreError: Error, Equatable {
    case unavailable
    case underlying(status: Int32)
}

protocol TokenStore: Sendable {
    func get() throws -> String?
    func set(_ token: String) throws
    func delete() throws
}
