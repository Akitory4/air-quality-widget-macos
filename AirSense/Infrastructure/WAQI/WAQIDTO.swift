// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import Foundation

struct WAQIEnvelope: Decodable {
    let status: String
    let data: Payload

    enum Payload: Decodable {
        case success(WAQIFeed)
        case failure(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                self = .failure(str)
                return
            }
            let feed = try container.decode(WAQIFeed.self)
            self = .success(feed)
        }
    }
}

struct WAQIFeed: Decodable {
    let aqi: Double?              // overall US EPA AQI
    let idx: Int?                 // internal station ID
    let time: Time?
    let city: CityInfo?
    let iaqi: IAQI?
    let attributions: [Attribution]?

    struct Time: Decodable {
        let iso: String?
    }

    struct CityInfo: Decodable {
        let name: String?
        let geo: [Double]?        // [lat, lon]
    }

    struct IAQI: Decodable {
        let pm25: IAQIValue?
        let pm10: IAQIValue?
        let o3:   IAQIValue?
        let no2:  IAQIValue?
        let so2:  IAQIValue?
        let co:   IAQIValue?
    }

    struct IAQIValue: Decodable {
        let v: Double?
    }

    struct Attribution: Decodable {
        let name: String?
        let url: String?
    }
}
