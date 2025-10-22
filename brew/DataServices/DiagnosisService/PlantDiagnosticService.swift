//
//  PlantDiagnosticService.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import CoreML
@preconcurrency import Vision
import UIKit

// MARK: - Classification Result (CoreML Output)
struct ClassificationResult: Codable, Identifiable {
    let id = UUID()
    let identifier: String
    let confidence: Float
    let nutrient: String?
    let severity: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case identifier, confidence, nutrient, severity, displayName
    }
}

// MARK: - Plant Diagnostic Service (CoreML Only)
/// Handles local CoreML model inference for plant disease/deficiency detection
class PlantDiagnosticService: ObservableObject {
    static let shared = PlantDiagnosticService()
    
    private var model: VNCoreMLModel?
    @Published var isModelLoaded = false
    @Published var modelError: String?
    
    private init() {
        loadModel()
    }
    
    // MARK: - Model Loading
    private func loadModel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .all
                
                let mlModel = try PlantDiagnostic(configuration: config)
                let visionModel = try VNCoreMLModel(for: mlModel.model)
                
                DispatchQueue.main.async {
                    self?.model = visionModel
                    self?.isModelLoaded = true
                    print("✅ PlantDiagnostic CoreML model loaded successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.modelError = error.localizedDescription
                    print("❌ Failed to load CoreML model: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Image Classification
    /// Classifies a plant image using the local CoreML model
    func classifyImage(_ image: UIImage) async throws -> [ClassificationResult] {
        guard let model = model else {
            throw PlantDiagnosticError.modelNotLoaded
        }
        
        guard let ciImage = CIImage(image: image) else {
            throw PlantDiagnosticError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                if let error = error {
                    continuation.resume(throwing: PlantDiagnosticError.classificationFailed(error))
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(throwing: PlantDiagnosticError.noResults)
                    return
                }
                
                let classifications = self?.processResults(results) ?? []
                continuation.resume(returning: classifications)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: PlantDiagnosticError.classificationFailed(error))
                }
            }
        }
    }
    
    /// Legacy callback-based classification method (for backward compatibility)
    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        Task {
            do {
                let results = try await classifyImage(image)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Result Processing
    private func processResults(_ observations: [VNClassificationObservation]) -> [ClassificationResult] {
        observations
            .filter { $0.confidence > 0.1 } // Filter low confidence results
            .map { observation in
                ClassificationResult(
                    identifier: observation.identifier,
                    confidence: observation.confidence,
                    nutrient: mapToNutrient(observation.identifier),
                    severity: determineSeverity(confidence: observation.confidence),
                    displayName: displayName(for: observation.identifier)
                )
            }
            .sorted { $0.confidence > $1.confidence } // Sort by confidence
    }
    
    // MARK: - Mapping Helpers
    private func mapToNutrient(_ identifier: String) -> String? {
        let lowercased = identifier.lowercased()
        
        switch lowercased {
        case "nitrogeno", "nitrogen":
            return "nitrogen"
        case "fosforo", "phosphorus":
            return "phosphorus"
        case "potasio", "potassium":
            return "potassium"
        case "calcio", "calcium":
            return "calcium"
        case "magnesio", "magnesium":
            return "magnesium"
        case "hierro", "iron":
            return "iron"
        case "manganeso", "manganese":
            return "manganese"
        case "zinc":
            return "zinc"
        case "azufre", "sulfur":
            return "sulfur"
        case "boro", "boron":
            return "boron"
        default:
            return nil
        }
    }
    
    private func determineSeverity(confidence: Float) -> String {
        switch confidence {
        case 0.8...1.0:
            return "severe"
        case 0.5..<0.8:
            return "moderate"
        default:
            return "mild"
        }
    }
    
    private func displayName(for identifier: String) -> String {
        let lowercased = identifier.lowercased()
        
        switch lowercased {
        case "saludable", "healthy":
            return "Planta Saludable"
        case "broca":
            return "Plaga: Broca del Café"
        case "roya":
            return "Enfermedad: Roya del Café"
        case "nitrogeno", "nitrogen":
            return "Deficiencia de Nitrógeno"
        case "fosforo", "phosphorus":
            return "Deficiencia de Fósforo"
        case "potasio", "potassium":
            return "Deficiencia de Potasio"
        case "calcio", "calcium":
            return "Deficiencia de Calcio"
        case "magnesio", "magnesium":
            return "Deficiencia de Magnesio"
        case "hierro", "iron":
            return "Deficiencia de Hierro"
        case "manganeso", "manganese":
            return "Deficiencia de Manganeso"
        case "zinc":
            return "Deficiencia de Zinc"
        case "azufre", "sulfur":
            return "Deficiencia de Azufre"
        case "boro", "boron":
            return "Deficiencia de Boro"
        default:
            return "Deficiencia de \(identifier.capitalized)"
        }
    }
    
    // MARK: - Utility Methods
    /// Maps detection state from confidence level
    func detectionStateFromConfidence(_ confidence: Float) -> DetectionState {
        return DetectionState.fromConfidence(confidence)
    }
    
    /// Gets the primary deficiency from classification results
    func getPrimaryDeficiency(from results: [ClassificationResult]) -> ClassificationResult? {
        results.first { $0.identifier.lowercased() != "saludable" && $0.identifier.lowercased() != "healthy" }
            ?? results.first
    }
}

// MARK: - Plant Diagnostic Error
enum PlantDiagnosticError: LocalizedError {
    case modelNotLoaded
    case invalidImage
    case classificationFailed(Error)
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "El modelo CoreML no está cargado"
        case .invalidImage:
            return "Imagen inválida"
        case .classificationFailed(let error):
            return "Fallo en la clasificación: \(error.localizedDescription)"
        case .noResults:
            return "No se obtuvieron resultados"
        }
    }
}
