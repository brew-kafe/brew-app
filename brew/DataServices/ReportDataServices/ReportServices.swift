//
//  ReportServices.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import Foundation

class APIReportService {
    private let baseURL = "https://brew-api-production.up.railway.app/api/reports"

    private var decoder: JSONDecoder {
        let d = JSONDecoder()

        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",  // microseconds
                "yyyy-MM-dd'T'HH:mm:ss.SSS",     // milliseconds
                "yyyy-MM-dd'T'HH:mm:ss"          // seconds only
            ]

            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateStr)"
            )
        }

        return d
    }
}
