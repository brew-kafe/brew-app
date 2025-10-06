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
struct ClassificationResult {
    let identifier: String
    let confidence: Float
    let nutrient: NutrientType?
    let severity: DeficiencySeverity
    
    var displayName: String {
        switch identifier.lowercased() {
        case "nitrogeno": return "Deficiencia de Nitrógeno"
        case "fosforo": return "Deficiencia de Fósforo"
        case "potasio": return "Deficiencia de Potasio"
        case "calcio": return "Deficiencia de Calcio"
        case "magnesio": return "Deficiencia de Magnesio"
        case "hierro": return "Deficiencia de Hierro"
        case "manganeso": return "Deficiencia de Manganeso"
        case "zinc": return "Deficiencia de Zinc"
        case "broca": return "Plaga: Broca del Café"
        case "roya": return "Enfermedad: Roya del Café"
        case "saludable": return "Planta Saludable"
        default: return identifier.capitalized
        }
    }
}

// MARK: - Plant Diagnostic Service
class PlantDiagnosticService {
    static let shared = PlantDiagnosticService()
    
    private var model: VNCoreMLModel?
    
    private init() {
        loadModel()
    }
    
    // MARK: - Load Model
    private func loadModel() {
        do {
            // Load the Core ML model
            let config = MLModelConfiguration()
            config.computeUnits = .all // Use all available compute units (CPU, GPU, Neural Engine)
            
            let mlModel = try PlantDiagnostic(configuration: config)
            model = try VNCoreMLModel(for: mlModel.model)
            
            print("✅ PlantDiagnostic_1 model loaded successfully")
        } catch {
            print("❌ Failed to load Core ML model: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Classify Image
    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        print("🔬 PlantDiagnosticService.classifyImage called")
        
        guard let model = model else {
            print("❌ Model not loaded!")
            completion(.failure(NSError(domain: "PlantDiagnosticService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])))
            return
        }
        
        print("✅ Model is loaded")
        
        guard let ciImage = CIImage(image: image) else {
            print("❌ Failed to convert to CIImage")
            completion(.failure(NSError(domain: "PlantDiagnosticService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])))
            return
        }
        
        print("✅ CIImage created")
        
        // Create Vision request
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            print("📥 Vision request completed")
            
            if let error = error {
                print("❌ Vision request error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("❌ No classification observations in results")
                completion(.failure(NSError(domain: "PlantDiagnosticService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No results"])))
                return
            }
            
            print("✅ Got \(results.count) classification results")
            
            // Log all results
            for (index, result) in results.prefix(5).enumerated() {
                print("   \(index + 1). \(result.identifier): \(String(format: "%.2f%%", result.confidence * 100))")
            }
            
            // Process results
            let classifications = self?.processResults(results) ?? []
            print("✅ Processed \(classifications.count) classifications")
            
            completion(.success(classifications))
        }
        
        // Configure request
        request.imageCropAndScaleOption = .centerCrop
        
        print("🎬 Performing Vision request...")
        
        // Perform request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                print("✅ Vision handler performed successfully")
            } catch {
                print("❌ Vision handler error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Process Results
    private func processResults(_ observations: [VNClassificationObservation]) -> [ClassificationResult] {
        return observations
            .filter { $0.confidence > 0.1 } // Filter low confidence results
            .map { observation in
                let nutrient = mapToNutrient(observation.identifier)
                let severity = determineSeverity(confidence: observation.confidence, identifier: observation.identifier)
                
                return ClassificationResult(
                    identifier: observation.identifier,
                    confidence: observation.confidence,
                    nutrient: nutrient,
                    severity: severity
                )
            }
            .sorted { $0.confidence > $1.confidence }
    }
    
    // MARK: - Map to Nutrient
    private func mapToNutrient(_ identifier: String) -> NutrientType? {
        switch identifier.lowercased() {
        case "nitrogeno": return .nitrogen
        case "fosforo": return .phosphorus
        case "potasio": return .potassium
        case "calcio": return .calcium
        case "magnesio": return .magnesium
        case "hierro": return .iron
        case "manganeso": return .manganese
        case "zinc": return .zinc
        default: return nil
        }
    }
    
    // MARK: - Determine Severity
    private func determineSeverity(confidence: Float, identifier: String) -> DeficiencySeverity {
        // If it's healthy or pest/disease, return low severity
        if identifier.lowercased() == "saludable" || identifier.lowercased() == "broca" || identifier.lowercased() == "roya" {
            return .low
        }
        
        // Determine severity based on confidence level
        if confidence >= 0.8 {
            return .severe
        } else if confidence >= 0.5 {
            return .moderate
        } else {
            return .low
        }
    }
    
    // MARK: - Generate Recommendations
    func generateRecommendations(for result: ClassificationResult, totalPlants: Int) -> String {
        guard let nutrient = result.nutrient else {
            // Handle pests/diseases or healthy plants
            if result.identifier.lowercased() == "saludable" {
                return "La planta se encuentra en buen estado. Continuar con el manejo regular del cultivo."
            } else if result.identifier.lowercased() == "broca" {
                return "Aplicar control integrado de broca: trampas, control cultural y químico según sea necesario. Realizar cosecha sanitaria."
            } else if result.identifier.lowercased() == "roya" {
                return "Aplicar fungicidas sistémicos. Mejorar la ventilación del cultivo. Considerar variedades resistentes."
            }
            return "Consultar con un agrónomo especializado."
        }
        
        // Generate recommendations based on nutrient deficiency
        switch nutrient {
        case .nitrogen:
            return """
            Aplicar urea (46%) a razón de 100-150 kg/ha o sulfato de amonio (21%) a razón de 200-300 kg/ha.
            Fertilizar en períodos de lluvia o con riego disponible.
            Considerar abonos verdes o compost para mejorar el contenido de materia orgánica.
            """
        case .phosphorus:
            return """
            Aplicar fosfato diamónico (DAP) a razón de 50-100 kg/ha o superfosfato triple a razón de 100-150 kg/ha.
            Incorporar al suelo cerca de la zona radicular.
            Verificar pH del suelo (óptimo 5.5-6.5 para disponibilidad de P).
            """
        case .potassium:
            return """
            Aplicar cloruro de potasio (KCl) a razón de 100-200 kg/ha o sulfato de potasio a razón de 150-250 kg/ha.
            Fraccionar la aplicación en 2-3 dosis durante el ciclo productivo.
            Monitorear niveles de Ca y Mg para mantener balance catiónico.
            """
        case .calcium:
            return """
            Aplicar cal agrícola (CaCO3) según análisis de suelo, generalmente 500-1000 kg/ha.
            Considerar yeso agrícola (CaSO4) en suelos con pH adecuado pero deficientes en Ca.
            Aplicar en dosis fraccionadas y mezclar con el suelo.
            """
        case .magnesium:
            return """
            Aplicar sulfato de magnesio (sal de Epsom) a razón de 50-100 kg/ha vía suelo.
            Para corrección rápida, usar aspersión foliar al 1-2%.
            Considerar cal dolomítica si también hay deficiencia de calcio.
            """
        case .iron:
            return """
            Aplicar quelatos de hierro (Fe-EDTA o Fe-EDDHA) vía foliar al 0.1-0.3%.
            Corregir pH del suelo si es superior a 7.0.
            Aplicar sulfato ferroso al suelo en dosis de 10-20 kg/ha.
            """
        case .manganese:
            return """
            Aplicar sulfato de manganeso vía foliar al 0.2-0.5%.
            En suelo, aplicar 5-10 kg/ha de sulfato de manganeso.
            Evitar encalado excesivo que reduce disponibilidad de Mn.
            """
        case .zinc:
            return """
            Aplicar sulfato de zinc vía foliar al 0.2-0.5%.
            En suelo, aplicar 10-20 kg/ha de sulfato de zinc.
            Repetir aplicaciones cada 15-20 días hasta ver mejoría.
            """
        }
    }
}
