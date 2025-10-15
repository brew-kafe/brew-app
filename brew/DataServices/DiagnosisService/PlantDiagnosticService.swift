//
//  PlantDiagnosticService.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import CoreML
import Vision
import UIKit

// MARK: - Keep your existing ClassificationResult for CoreML
struct ClassificationResult: Codable {
    let identifier: String
    let confidence: Float
    let nutrient: String?
    let severity: String
    let displayName: String
}

// MARK: - Updated API Configuration
struct APIConfig {
    static let baseURL = "http://127.0.0.1:8000/api"  // Updated to match your FastAPI structure
}

// MARK: - Updated Plant Diagnostic Service
class PlantDiagnosticService: ObservableObject {
    static let shared = PlantDiagnosticService()
    private var model: VNCoreMLModel?
    private let session = URLSession.shared
    
    private init() {
        loadModel()
    }

    // MARK: - Keep your existing CoreML functionality
    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let mlModel = try PlantDiagnostic(configuration: config)
            model = try VNCoreMLModel(for: mlModel.model)
            print("✅ PlantDiagnostic model loaded successfully")
        } catch {
            print("❌ Failed to load CoreML model: \(error.localizedDescription)")
        }
    }

    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        guard let model = model else {
            completion(.failure(NSError(domain: "PlantDiagnosticService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])))
            return
        }

        guard let ciImage = CIImage(image: image) else {
            completion(.failure(NSError(domain: "PlantDiagnosticService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let results = request.results as? [VNClassificationObservation] else {
                completion(.failure(NSError(domain: "PlantDiagnosticService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No results"])))
                return
            }

            let classifications = self?.processResults(results) ?? []
            completion(.success(classifications))
        }

        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(ciImage: ciImage)

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func processResults(_ observations: [VNClassificationObservation]) -> [ClassificationResult] {
        observations
            .filter { $0.confidence > 0.1 }
            .map { obs in
                ClassificationResult(
                    identifier: obs.identifier,
                    confidence: obs.confidence,
                    nutrient: mapToNutrient(obs.identifier),
                    severity: determineSeverity(confidence: obs.confidence),
                    displayName: displayName(for: obs.identifier)
                )
            }
            .sorted { $0.confidence > $1.confidence }
    }

    private func mapToNutrient(_ id: String) -> String? {
        switch id.lowercased() {
        case "nitrogeno": return "nitrogen"
        case "fosforo": return "phosphorus"
        case "potasio": return "potassium"
        case "calcio": return "calcium"
        case "magnesio": return "magnesium"
        case "hierro": return "iron"
        case "manganeso": return "manganese"
        case "zinc": return "zinc"
        case "azufre": return "sulfur"
        case "boro": return "boron"
        default: return nil
        }
    }

    private func determineSeverity(confidence: Float) -> String {
        if confidence >= 0.8 { return "severe" }
        if confidence >= 0.5 { return "moderate" }
        return "mild"
    }

    private func displayName(for id: String) -> String {
        switch id.lowercased() {
        case "saludable": return "Planta Saludable"
        case "broca": return "Plaga: Broca del Café"
        case "roya": return "Enfermedad: Roya del Café"
        default: return "Deficiencia de \(id.capitalized)"
        }
    }

    // MARK: - New API Methods matching your diagnosis endpoints
    func analyzePhoto(
        image: UIImage,
        parcelName: String = "Unknown Parcel",
        technicianName: String = "Unknown Technician"
    ) async throws -> PhotoAnalysisResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/diagnosis/analyze-photo") else {
            throw DiagnosisError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(
            image: image,
            parcelName: parcelName,
            technicianName: technicianName,
            boundary: boundary
        )
        
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DiagnosisError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(PhotoAnalysisResponse.self, from: data)
    }
    
    func createDiagnosisFromAnalysis(
        request: DiagnosisCreateRequest
    ) async throws -> DiagnosisCreateResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/diagnosis/create-from-diagnosis") else {
            throw DiagnosisError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DiagnosisError.serverError
        }
        
        return try JSONDecoder().decode(DiagnosisCreateResponse.self, from: data)
    }
    
    func getDetectionStates() async throws -> DetectionStateResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/diagnosis/detection-states") else {
            throw DiagnosisError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(DetectionStateResponse.self, from: data)
    }
    
    func getSupportedElements() async throws -> ElementListResponse {
        guard let url = URL(string: "\(APIConfig.baseURL)/diagnosis/elements") else {
            throw DiagnosisError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(ElementListResponse.self, from: data)
    }
    
    // MARK: - Helper method for multipart form data
    private func createMultipartBody(
        image: UIImage,
        parcelName: String,
        technicianName: String,
        boundary: String
    ) -> Data {
        var body = Data()
        
        // Add image file
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"plant.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add parcel_name
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"parcel_name\"\r\n\r\n".data(using: .utf8)!)
        body.append(parcelName.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add technician_name
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"technician_name\"\r\n\r\n".data(using: .utf8)!)
        body.append(technicianName.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    // MARK: - Legacy methods (keep for backward compatibility if needed)
    func uploadDiagnosis(_ diagnosis: DiagnosisDTO, completion: @escaping (Result<DiagnosisDTO, Error>) -> Void) {
        // Keep your existing implementation if still needed
        var request = URLRequest(url: URL(string: "\(APIConfig.baseURL)/diagnosis")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(diagnosis)
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(DiagnosisDTO.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum DiagnosisError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError: return "Server Error"
        case .decodingError: return "Failed to decode response"
        case .networkError: return "Network Error"
        }
    }
}
