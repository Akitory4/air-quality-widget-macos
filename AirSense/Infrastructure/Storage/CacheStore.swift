// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

actor CacheStore {
    private let fileURL: URL
    private var inMemory: AirQualitySnapshot?

    init(fileManager: FileManager = .default) {
        let dir = SharedStorage.containerDirectory()
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent(SharedStorage.snapshotFileName)
    }

    func load() -> AirQualitySnapshot? {
        if let inMemory { return inMemory }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let snapshot = try? decoder.decode(AirQualitySnapshot.self, from: data)
        inMemory = snapshot
        return snapshot
    }

    func save(_ snapshot: AirQualitySnapshot) {
        inMemory = snapshot
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func clear() {
        inMemory = nil
        try? FileManager.default.removeItem(at: fileURL)
    }
}
