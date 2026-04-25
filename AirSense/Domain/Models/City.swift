// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

struct Coordinate: Equatable, Codable, Sendable {
    let latitude: Double
    let longitude: Double
}

struct City: Equatable, Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let region: String?
    let country: String?
    let coordinate: Coordinate

    init(name: String, region: String?, country: String?, coordinate: Coordinate) {
        self.id = "\(coordinate.latitude),\(coordinate.longitude)"
        self.name = name
        self.region = region
        self.country = country
        self.coordinate = coordinate
    }

    var displayName: String {
        if let country { return "\(name), \(country)" }
        return name
    }

    var formattedCoordinates: String {
        let latHemi = coordinate.latitude >= 0 ? "N" : "S"
        let lonHemi = coordinate.longitude >= 0 ? "E" : "W"
        return String(
            format: "%.2f°%@, %.2f°%@",
            abs(coordinate.latitude), latHemi,
            abs(coordinate.longitude), lonHemi
        )
    }
}

extension City {
    static let limassol = City(
        name: "Limassol",
        region: "Limassol, Cyprus",
        country: "CY",
        coordinate: Coordinate(latitude: 34.68, longitude: 33.04)
    )
    static let nicosia = City(
        name: "Nicosia",
        region: "Nicosia, Cyprus",
        country: "CY",
        coordinate: Coordinate(latitude: 35.17, longitude: 33.36)
    )
    static let paphos = City(
        name: "Paphos",
        region: "Paphos, Cyprus",
        country: "CY",
        coordinate: Coordinate(latitude: 34.77, longitude: 32.42)
    )
}
