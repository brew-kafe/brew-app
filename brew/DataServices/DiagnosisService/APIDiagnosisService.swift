//
//  APIDiagnosisService.swift
//  brew
//
//  Created by toño on 21/10/25.
//

import Foundation
import UIKit

// MARK: - API Configuration
struct APIConfiguration {
    static let baseURL = "https://brew-api-production.up.railway.app/api"
    static let timeout: TimeInterval = 30
}

// MARK: - API Diagnosis Service
class APIDiagnosisService: ObservableObject {
    static let shared = APIDiagnosisService()
    
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
        // Custom date decoder to handle API date format with microseconds
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
    
    // MARK: - Photo Analysis (DISABLED - endpoint doesn't exist)
    /// Analyzes a plant photo using the backend AI model
    /// NOTE: This endpoint doesn't exist in the current API, keeping for future implementation
    /*
    func analyzePhoto(
        image: UIImage,
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String
    ) async throws -> PhotoAnalysisResponse {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/analyze-photo") else {
            throw APIDiagnosisError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(
            image: image,
            parcelName: parcelName,
            plantNumber: plantNumber,
            technicianName: technicianName,
            boundary: boundary
        )
        
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIDiagnosisError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIDiagnosisError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(PhotoAnalysisResponse.self, from: data)
        } catch let error as APIDiagnosisError {
            throw error
        } catch {
            throw APIDiagnosisError.networkError(error)
        }
    }
    */
    
    // MARK: - Create Diagnosis
    /// Creates a diagnosis record in the backend database
    func createDiagnosis(
        request: DiagnosisCreateAPIRequest
    ) async throws -> DiagnosisAPIResponse {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/") else {
            throw APIDiagnosisError.invalidURL
        }
        
        print("🚀 Creating diagnosis with URL: \(url)")
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
                throw APIDiagnosisError.invalidResponse
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            print("📄 Response data: \(String(data: data, encoding: .utf8) ?? "Could not decode")")
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                throw APIDiagnosisError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let diagnosisResponse = try decoder.decode(DiagnosisAPIResponse.self, from: data)
            print("✅ Successfully created diagnosis with ID: \(diagnosisResponse.id)")
            return diagnosisResponse
        } catch let error as APIDiagnosisError {
            print("❌ APIDiagnosisError: \(error)")
            throw error
        } catch {
            print("❌ Network error: \(error)")
            throw APIDiagnosisError.networkError(error)
        }
    }
    
    // MARK: - Fetch Diagnoses
    /// Fetches all diagnoses for a specific user
    func fetchDiagnoses(userId: String) async throws -> [DiagnosisAPIResponse] {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/user/\(userId)") else {
            throw APIDiagnosisError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIDiagnosisError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIDiagnosisError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode([DiagnosisAPIResponse].self, from: data)
        } catch let error as APIDiagnosisError {
            throw error
        } catch {
            throw APIDiagnosisError.networkError(error)
        }
    }
    
    // MARK: - Fetch Single Diagnosis
    /// Fetches a specific diagnosis by ID
    func fetchDiagnosis(diagnosisId: String) async throws -> DiagnosisAPIResponse {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/\(diagnosisId)") else {
            throw APIDiagnosisError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIDiagnosisError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIDiagnosisError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(DiagnosisAPIResponse.self, from: data)
        } catch let error as APIDiagnosisError {
            throw error
        } catch {
            throw APIDiagnosisError.networkError(error)
        }
    }
    
    // MARK: - Delete Diagnosis
    /// Deletes a diagnosis from the backend
    func deleteDiagnosis(diagnosisId: String) async throws {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/\(diagnosisId)") else {
            throw APIDiagnosisError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIDiagnosisError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                throw APIDiagnosisError.deleteFailed
            }
        } catch let error as APIDiagnosisError {
            throw error
        } catch {
            throw APIDiagnosisError.networkError(error)
        }
    }
    
    // MARK: - Get Detection States
    /// Fetches available detection states from the backend
    func getDetectionStates() async throws -> DetectionStateResponse {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/detection-states") else {
            throw APIDiagnosisError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIDiagnosisError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIDiagnosisError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(DetectionStateResponse.self, from: data)
        } catch let error as APIDiagnosisError {
            throw error
        } catch {
            throw APIDiagnosisError.networkError(error)
        }
    }
    
    // MARK: - Get Supported Elements
    /// Fetches list of supported nutrient elements
    func getSupportedElements() async throws -> ElementListResponse {
        guard let url = URL(string: "\(APIConfiguration.baseURL)/diagnosis/elements") else {
            throw APIDiagnosisError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIDiagnosisError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIDiagnosisError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(ElementListResponse.self, from: data)
        } catch let error as APIDiagnosisError {
            throw error
        } catch {
            throw APIDiagnosisError.networkError(error)
        }
    }
    
    // MARK: - Helper Methods
    private func createMultipartBody(
        image: UIImage,
        parcelName: String,
        plantNumber: String?,
        technicianName: String,
        boundary: String
    ) -> Data {
        var body = Data()
        
        // Add image file
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"plant.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        // Add parcel_name
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"parcel_name\"\r\n\r\n")
        body.append(parcelName)
        body.append("\r\n")
        
        // Add plant_number if provided
        if let plantNumber = plantNumber {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"plant_number\"\r\n\r\n")
            body.append(plantNumber)
            body.append("\r\n")
        }
        
        // Add technician_name
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"technician_name\"\r\n\r\n")
        body.append(technicianName)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
}

// MARK: - Data Extension
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - API Diagnosis Error
enum APIDiagnosisError: LocalizedError {
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
            return "No se pudo eliminar el diagnóstico"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        }
    }
}
