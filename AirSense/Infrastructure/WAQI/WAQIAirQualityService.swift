// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

/// Air-quality service backed by the World Air Quality Index project.
final class WAQIAirQualityService: AirQualityService {
    private let client: HTTPClient
    private let tokenStore: TokenStore
    private let baseURL = ServiceEndpoints.WAQI.apiBase

    init(client: HTTPClient, tokenStore: TokenStore) {
        self.client = client
        self.tokenStore = tokenStore
    }

    func fetchSnapshot(for city: City, standard: AQIStandard) async throws -> AirQualitySnapshot {
        let token = try resolveToken()
        let url = try buildURL(lat: city.coordinate.latitude, lng: city.coordinate.longitude, token: token)

        let envelope: WAQIEnvelope
        do {
            envelope = try await client.get(url, as: WAQIEnvelope.self)
        } catch let error as HTTPError {
            throw Self.translate(httpError: error)
        }

        switch envelope.data {
        case .success(let feed):
            return Self.map(feed: feed, fallbackCity: city)
        case .failure(let message):
            throw Self.classify(errorMessage: message, envelopeStatus: envelope.status)
        }
    }

    // MARK: - Token

    private func resolveToken() throws -> String {
        let token: String?
        do {
            token = try tokenStore.get()
        } catch {
            throw WAQIError.missingToken
        }
        guard let token, !token.isEmpty else {
            throw WAQIError.missingToken
        }
        return token
    }

    private func buildURL(lat: Double, lng: Double, token: String) throws -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent("feed/geo:\(lat);\(lng)/"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "token", value: token)]
        guard let url = components?.url else { throw WAQIError.decoding("invalid URL") }
        return url
    }

    // MARK: - Mapping

    static func map(feed: WAQIFeed, fallbackCity: City) -> AirQualitySnapshot {
        let aqi = Int((feed.aqi ?? 0).rounded())

        let pollutants = Pollutants(
            pm25: feed.iaqi?.pm25?.v,
            pm10: feed.iaqi?.pm10?.v,
            o3:   feed.iaqi?.o3?.v,
            no2:  feed.iaqi?.no2?.v,
            so2:  feed.iaqi?.so2?.v,
            co:   feed.iaqi?.co?.v,
            units: .usAqiSubIndex
        )

        let observedAt = parseISO8601(feed.time?.iso) ?? Date()

        let city = fallbackCity
        let stationName = feed.city?.name
        let attributions: [String]? = feed.attributions?.compactMap { a in
            guard let name = a.name, !name.isEmpty else { return nil }
            if let url = a.url, !url.isEmpty { return "\(name) — \(url)" }
            return name
        }

        return AirQualitySnapshot(
            city: city,
            observedAt: observedAt,
            fetchedAt: Date(),
            aqi: aqi,
            standard: .usEpa,
            pollutants: pollutants,
            stationName: stationName,
            attributions: (attributions?.isEmpty == false) ? attributions : nil
        )
    }

    private static func parseISO8601(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: raw) { return date }
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: raw)
    }

    // MARK: - Error classification

    static func translate(httpError: HTTPError) -> WAQIError {
        switch httpError {
        case .invalidURL:
            return .decoding("invalid URL")
        case .transport(let msg):
            return .transport(msg)
        case .badStatus(let code) where code == 429:
            return .rateLimited
        case .badStatus(let code):
            return .upstream("HTTP \(code)")
        case .decoding(let msg):
            return .decoding(msg)
        }
    }

    static func classify(errorMessage message: String, envelopeStatus: String) -> WAQIError {
        let normalized = message.lowercased()
        if normalized.contains("invalid key") || normalized.contains("wrong api key") {
            return .invalidToken
        }
        if normalized.contains("unknown station") || normalized.contains("no data") {
            return .unknownStation
        }
        if normalized.contains("over quota") || normalized.contains("too many requests") {
            return .rateLimited
        }
        return .upstream(message)
    }
}
