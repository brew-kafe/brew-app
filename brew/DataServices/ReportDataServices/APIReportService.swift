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
        self.decoder.dateDecodingStrategy = .iso8601
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
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIReportError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                throw APIReportError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(ReportAPIResponse.self, from: data)
        } catch let error as APIReportError {
            throw error
        } catch {
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
