// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation
import Security

final class KeychainTokenStore: TokenStore, @unchecked Sendable {
    private let service: String
    private let account: String

    init(
        service: String = Bundle.main.bundleIdentifier ?? AppConfiguration.Keychain.defaultService,
        account: String
    ) {
        self.service = service
        self.account = account
    }

    func get() throws -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            guard let data = item as? Data, let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            return string
        case errSecItemNotFound:
            return nil
        default:
            throw TokenStoreError.underlying(status: status)
        }
    }

    func set(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw TokenStoreError.unavailable
        }
        let base = baseQuery()

        let updateStatus = SecItemUpdate(base as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var addQuery = base
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus != errSecSuccess {
                throw TokenStoreError.underlying(status: addStatus)
            }
        default:
            throw TokenStoreError.underlying(status: updateStatus)
        }
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw TokenStoreError.underlying(status: status)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
