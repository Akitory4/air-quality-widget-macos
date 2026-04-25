// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

struct OpenMeteoGeocodingDTO: Decodable {
    struct Result: Decodable {
        let name: String
        let admin1: String?
        let country: String?
        let country_code: String?
        let latitude: Double
        let longitude: Double
    }
    let results: [Result]?
}

final class OpenMeteoGeocodingService: GeocodingService {
    private let client: HTTPClient
    private let searchURL = ServiceEndpoints.OpenMeteo.geocodingSearchAPI
    private let reverseURL = ServiceEndpoints.OpenMeteo.geocodingReverseAPI

    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    func search(query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else { return [] }
        var components = URLComponents(url: searchURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "name", value: trimmed),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components.url else { throw HTTPError.invalidURL }
        let dto = try await client.get(url, as: OpenMeteoGeocodingDTO.self)
        return Self.map(dto: dto)
    }

    func reverse(coordinate: Coordinate) async throws -> City? {
        var components = URLComponents(url: reverseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components.url else { throw HTTPError.invalidURL }
        let dto = try await client.get(url, as: OpenMeteoGeocodingDTO.self)
        return Self.map(dto: dto).first
    }

    static func map(dto: OpenMeteoGeocodingDTO) -> [City] {
        (dto.results ?? []).map { result in
            let region: String?
            if let admin = result.admin1, let country = result.country {
                region = "\(admin), \(country)"
            } else {
                region = result.admin1 ?? result.country
            }
            return City(
                name: result.name,
                region: region,
                country: result.country_code,
                coordinate: Coordinate(latitude: result.latitude, longitude: result.longitude)
            )
        }
    }
}
