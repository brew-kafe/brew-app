//
//  APIReportService.swift
//  brew
//
//  Created by toño on 22/10/25.
//

import Foundation
import UIKit

// MARK: - API Report Service
/// Handles all report-related API operations
class APIReportService: ObservableObject {
    static let shared = APIReportService()
    
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfiguration.timeout
        config.timeoutIntervalForResource = APIConfiguration.timeout
        self.session = URLSession(configuration: config)
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        
        self.decoder = JSONDecoder()
        // Custom date decoder to handle API date format with microseconds (same as diagnosis service)
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try different date formats
            let formatters: [DateFormatter] = [
                // API format with microseconds: "2025-10-27T05:37:51.235170"
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                // Standard ISO8601 format: "2025-10-27T05:37:51Z"
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                // ISO8601 without Z: "2025-10-27T05:37:51"
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }()
            ]
            
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot decode date string \(dateString). Expected formats: yyyy-MM-dd'T'HH:mm:ss.SSSSSS, yyyy-MM-dd'T'HH:mm:ss'Z', or yyyy-MM-dd'T'HH:mm:ss"
                )
            )
        }
    }
    
    // MARK: - Create Report
    /// Creates a new report linked to diagnoses
    func createReport(
        userId: UUID,
        request: ReportCreateRequest
    ) async throws -> ReportAPIResponse {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/reports/") else {
            throw APIReportError.invalidURL
        }
        
        print("🚀 Creating report with URL: \(url)")
        print("📝 Request data: \(request)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = try encoder.encode(request)
            urlRequest.httpBody = requestBody
            
            print("📤 Sending POST request to: \(url)")
            print("📦 Request body: \(String(data: requestBody, encoding: .utf8) ?? "Could not decode")")
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIReportError.invalidResponse
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            print("📄 Response data: \(String(data: data, encoding: .utf8) ?? "Could not decode")")
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                throw APIReportError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let reportResponse = try decoder.decode(ReportAPIResponse.self, from: data)
            print("✅ Successfully created report with ID: \(reportResponse.reportId)")
            return reportResponse
        } catch let error as APIReportError {
            print("❌ APIReportError: \(error)")
            throw error
        } catch {
            print("❌ Network error: \(error)")
            throw APIReportError.networkError(error)
        }
    }
    
    // MARK: - Fetch User Reports
    /// Fetches all reports for a specific user
    func fetchReports(
        userId: UUID,
        skip: Int = 0,
        limit: Int = 50
    ) async throws -> [ReportAPIResponse] {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/reports/user/\(userId.uuidString)?skip=\(skip)&limit=\(limit)") else {
            throw APIReportError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIReportError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIReportError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode([ReportAPIResponse].self, from: data)
        } catch let error as APIReportError {
            throw error
        } catch {
            throw APIReportError.networkError(error)
        }
    }
    
    // MARK: - Fetch Single Report with Diagnoses
    /// Fetches a specific report with its linked diagnoses
    func fetchReportWithDiagnoses(reportId: Int) async throws -> ReportWithDiagnosesAPI {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/reports/\(reportId)") else {
            throw APIReportError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIReportError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIReportError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(ReportWithDiagnosesAPI.self, from: data)
        } catch let error as APIReportError {
            throw error
        } catch {
            throw APIReportError.networkError(error)
        }
    }
    
    // MARK: - Delete Report
    /// Deletes a report from the backend
    func deleteReport(reportId: Int) async throws {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/reports/\(reportId)") else {
            throw APIReportError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIReportError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                throw APIReportError.deleteFailed
            }
        } catch let error as APIReportError {
            throw error
        } catch {
            throw APIReportError.networkError(error)
        }
    }
    
    // MARK: - Link Diagnosis to Report
    /// Links an existing diagnosis to a report
    func linkDiagnosisToReport(
        reportId: Int,
        diagnosisId: UUID
    ) async throws {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/reports/\(reportId)/diagnoses/\(diagnosisId.uuidString)") else {
            throw APIReportError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIReportError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIReportError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as APIReportError {
            throw error
        } catch {
            throw APIReportError.networkError(error)
        }
    }
}

// MARK: - API Report Error
enum APIReportError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case networkError(Error)
    case deleteFailed
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .serverError(let code):
            return "Error del servidor (código: \(code))"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .deleteFailed:
            return "No se pudo eliminar el reporte"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        }
    }
}
