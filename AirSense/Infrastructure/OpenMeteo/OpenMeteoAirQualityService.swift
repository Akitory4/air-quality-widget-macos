// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

struct OpenMeteoAirQualityDTO: Decodable {
    struct Current: Decodable {
        let time: String?
        let european_aqi: Double?
        let us_aqi: Double?
        let pm2_5: Double?
        let pm10: Double?
        let ozone: Double?
        let nitrogen_dioxide: Double?
        let sulphur_dioxide: Double?
        let carbon_monoxide: Double?
    }
    let current: Current
}

final class OpenMeteoAirQualityService: AirQualityService {
    private let client: HTTPClient
    private let baseURL = ServiceEndpoints.OpenMeteo.airQualityAPI

    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    func fetchSnapshot(for city: City, standard: AQIStandard) async throws -> AirQualitySnapshot {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(city.coordinate.longitude)),
            URLQueryItem(name: "current", value: "european_aqi,us_aqi,pm2_5,pm10,ozone,nitrogen_dioxide,sulphur_dioxide,carbon_monoxide"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else { throw HTTPError.invalidURL }
        let dto = try await client.get(url, as: OpenMeteoAirQualityDTO.self)
        return Self.map(dto: dto, city: city, standard: standard)
    }

    static func map(dto: OpenMeteoAirQualityDTO, city: City, standard: AQIStandard) -> AirQualitySnapshot {
        let rawAQI: Double? = (standard == .european) ? dto.current.european_aqi : dto.current.us_aqi
        let aqi = Int((rawAQI ?? 0).rounded())
        let pollutants = Pollutants(
            pm25: dto.current.pm2_5,
            pm10: dto.current.pm10,
            o3:   dto.current.ozone,
            no2:  dto.current.nitrogen_dioxide,
            so2:  dto.current.sulphur_dioxide,
            co:   dto.current.carbon_monoxide.map { $0 / 1000 }
        )
        let observedAt = Self.parseTime(dto.current.time) ?? Date()
        return AirQualitySnapshot(
            city: city,
            observedAt: observedAt,
            fetchedAt: Date(),
            aqi: aqi,
            standard: standard,
            pollutants: pollutants
        )
    }

    private static func parseTime(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: raw) { return date }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f.date(from: raw)
    }
}
