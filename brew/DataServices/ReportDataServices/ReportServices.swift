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
    
    
    // MARK - Fetch reports for a list of reports from the API
    func fetchReports(completion: @escaping (Result<[DetailedReportData], APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/reports/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            // Check for HTTP errors
            guard 200...299 ~= httpResponse.statusCode else {
                print("HTTP Error: \(httpResponse.statusCode)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let reports = try self.decoder.decode([DetailedReportData].self, from: data)
                completion(.success(reports))
            } catch {
                print("Decoding error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(dataString)")
                }
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
}
