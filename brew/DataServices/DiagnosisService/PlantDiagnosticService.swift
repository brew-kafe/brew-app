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

// MARK: - Classification Result
struct ClassificationResult: Codable {
    let identifier: String
    let confidence: Float
    let nutrient: String?
    let severity: String
    let displayName: String
}

// MARK: - Diagnosis Model (to send/receive with API)
struct Diagnosis: Codable, Identifiable, Hashable {
    let id: UUID
    var parcelName: String
    var plantNumber: String
    var technicianName: String
    var classification: String
    var confidence: Float
    var severity: String
    var recommendation: String?
    var imageURL: String?
    var createdAt: Date?
}

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = URL(string: "http://127.0.0.1:8000")!
}

// MARK: - Plant Diagnostic Service
class PlantDiagnosticService {
    static let shared = PlantDiagnosticService()
    private var model: VNCoreMLModel?
    private let session = URLSession.shared
    
    private init() {
        loadModel()
    }

    // MARK: - Load Model
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

    // MARK: - Classify Image (Local CoreML)
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

    // MARK: - Process Results
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

    // MARK: - Mapping and Severity
    private func mapToNutrient(_ id: String) -> String? {
        switch id.lowercased() {
        case "nitrogeno": return "Nitrogen"
        case "fosforo": return "Phosphorus"
        case "potasio": return "Potassium"
        case "calcio": return "Calcium"
        case "magnesio": return "Magnesium"
        case "hierro": return "Iron"
        case "manganeso": return "Manganese"
        case "zinc": return "Zinc"
        default: return nil
        }
    }

    private func determineSeverity(confidence: Float) -> String {
        if confidence >= 0.8 { return "Severe" }
        if confidence >= 0.5 { return "Moderate" }
        return "Low"
    }

    private func displayName(for id: String) -> String {
        switch id.lowercased() {
        case "saludable": return "Planta Saludable"
        case "broca": return "Plaga: Broca del Café"
        case "roya": return "Enfermedad: Roya del Café"
        default: return "Deficiencia de \(id.capitalized)"
        }
    }

    // MARK: - API Interaction
    func uploadDiagnosis(_ diagnosis: Diagnosis, completion: @escaping (Result<Diagnosis, Error>) -> Void) {
        var request = URLRequest(url: APIConfig.baseURL.appendingPathComponent("/diagnosis"))
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
                let decoded = try JSONDecoder().decode(Diagnosis.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchDiagnoses(completion: @escaping (Result<[Diagnosis], Error>) -> Void) {
        let url = APIConfig.baseURL.appendingPathComponent("/diagnosis")
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Diagnosis].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
