//
//  DiagnosisViewModel.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI
import Combine

class DiagnosisViewModel: ObservableObject {
    @Published var diagnoses: [Diagnosis] = []
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let diagnosticService = PlantDiagnosticService.shared
    private let storageKey = "saved_diagnoses"
    
    init() {
        loadDiagnoses()
    }
    
    // MARK: - Analyze Photo
    func analyzePhoto(request: PhotoAnalysisRequest) {
        print("🎯 DiagnosisViewModel.analyzePhoto called")
        
        guard let image = UIImage(data: request.imageData) else {
            print("❌ Failed to create UIImage from data")
            showError(message: "No se pudo procesar la imagen")
            return
        }
        
        print("✅ UIImage created successfully: \(image.size)")
        print("🔄 Setting isAnalyzing = true")
        
        isAnalyzing = true
        
        print("📡 Calling diagnosticService.classifyImage...")
        
        diagnosticService.classifyImage(image) { [weak self] result in
            print("📬 Received classification result")
            
            DispatchQueue.main.async {
                print("🔄 Setting isAnalyzing = false")
                self?.isAnalyzing = false
                
                switch result {
                case .success(let classifications):
                    print("✅ Classification successful!")
                    print("📊 Number of classifications: \(classifications.count)")
                    
                    if let top = classifications.first {
                        print("🏆 Top result: \(top.identifier) (confidence: \(top.confidence))")
                    }
                    
                    self?.processDiagnosticResults(
                        classifications: classifications,
                        request: request
                    )
                    
                case .failure(let error):
                    print("❌ Classification failed: \(error.localizedDescription)")
                    self?.showError(message: "Error en el análisis: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Process Diagnostic Results
    private func processDiagnosticResults(
        classifications: [ClassificationResult],
        request: PhotoAnalysisRequest
    ) {
        guard let topResult = classifications.first else {
            showError(message: "No se pudo clasificar la imagen")
            return
        }
        
        // Calculate affected plants based on confidence
        let plantsAffected = Int(Float(request.totalPlants) * topResult.confidence)
        let percentage = topResult.confidence * 100
        
        // Generate diagnosis text
        let diagnosisText = generateDiagnosisText(
            topResult: topResult,
            classifications: classifications,
            totalPlants: request.totalPlants
        )
        
        // Create nutritional deficiencies array
        var deficiencies: [NutritionalDeficiency] = []
        
        if let nutrient = topResult.nutrient {
            let recommendations = diagnosticService.generateRecommendations(
                for: topResult,
                totalPlants: request.totalPlants
            )
            
            deficiencies.append(
                NutritionalDeficiency(
                    nutrient: nutrient,
                    severity: topResult.severity,
                    plantsAffected: plantsAffected,
                    percentage: Double(percentage),
                    recommendations: recommendations
                )
            )
        }
        
        // Add secondary deficiencies if confidence is significant
        for classification in classifications.dropFirst().prefix(2) {
            if classification.confidence >= 0.2, let nutrient = classification.nutrient {
                let secPlantsAffected = Int(Float(request.totalPlants) * classification.confidence)
                let secPercentage = classification.confidence * 100
                let recommendations = diagnosticService.generateRecommendations(
                    for: classification,
                    totalPlants: request.totalPlants
                )
                
                deficiencies.append(
                    NutritionalDeficiency(
                        nutrient: nutrient,
                        severity: classification.severity,
                        plantsAffected: secPlantsAffected,
                        percentage: Double(secPercentage),
                        recommendations: recommendations
                    )
                )
            }
        }
        
        // Determine overall health
        let overallHealth = determineOverallHealth(
            topResult: topResult,
            confidence: topResult.confidence
        )
        
        // Create diagnosis
        let diagnosis = Diagnosis(
            parcelName: request.parcelName,
            plantNumber: request.plantNumber,
            technicianName: request.technicianName,
            diagnosis: diagnosisText,
            nutritionalDeficiencies: deficiencies,
            overallHealth: overallHealth,
            imageData: request.imageData,
            notes: request.additionalNotes
        )
        
        // Save diagnosis
        diagnoses.insert(diagnosis, at: 0)
        saveDiagnoses()
        
        print("✅ Diagnosis saved successfully")
    }
    
    // MARK: - Generate Diagnosis Text
    private func generateDiagnosisText(
        topResult: ClassificationResult,
        classifications: [ClassificationResult],
        totalPlants: Int
    ) -> String {
        let confidence = Int(topResult.confidence * 100)
        var text = """
        Resultado del análisis de imagen con Core ML:
        
        📊 Clasificación principal: \(topResult.displayName)
        🎯 Nivel de confianza: \(confidence)%
        
        """
        
        // Add specific diagnosis based on classification
        if topResult.identifier.lowercased() == "saludable" {
            text += """
            La planta evaluada presenta un estado fitosanitario óptimo. Los tejidos foliares muestran coloración característica y no se observan síntomas evidentes de deficiencias nutricionales o presencia de plagas y enfermedades.
            
            Recomendaciones:
            • Mantener el programa de fertilización actual
            • Continuar con el monitoreo periódico
            • Mantener las prácticas culturales implementadas
            """
        } else if topResult.identifier.lowercased() == "broca" {
            text += """
            Se detectó presencia de Broca del Café (Hypothenemus hampei), una de las plagas más importantes del cultivo. Este insecto perfora los frutos y afecta la calidad del grano.
            
            Acciones inmediatas requeridas:
            • Implementar cosecha sanitaria (recoger frutos del suelo y remanentes)
            • Instalar trampas con atrayentes
            • Evaluar necesidad de control químico
            • Mejorar manejo cultural del cafetal
            """
        } else if topResult.identifier.lowercased() == "roya" {
            text += """
            Se identificó síntomas de Roya del Café (Hemileia vastatrix), una enfermedad fúngica que causa defoliación prematura y reduce la producción significativamente.
            
            Plan de acción:
            • Aplicar fungicidas sistémicos (triazoles o estrobilurinas)
            • Mejorar densidad del cafetal para mejor ventilación
            • Fortalecer programa nutricional
            • Considerar renovación con variedades resistentes
            """
        } else {
            text += """
            Se detectó una deficiencia nutricional que está afectando el desarrollo normal de las plantas. Esta condición puede reducir el crecimiento, la producción y la calidad del café si no se corrige oportunamente.
            
            Análisis detallado:
            • Sintomatología: Manifestaciones visuales compatibles con \(topResult.displayName.lowercased())
            • Severidad: \(topResult.severity.rawValue)
            • Plantas estimadas afectadas: \(Int(Float(totalPlants) * topResult.confidence)) de \(totalPlants) evaluadas
            """
        }
        
        // Add secondary classifications if relevant
        let secondaryResults = classifications.dropFirst().filter { $0.confidence >= 0.15 }
        if !secondaryResults.isEmpty {
            text += "\n\n⚠️ Condiciones secundarias detectadas:"
            for (index, result) in secondaryResults.prefix(2).enumerated() {
                text += "\n\(index + 1). \(result.displayName) (Confianza: \(Int(result.confidence * 100))%)"
            }
        }
        
        return text
    }
    
    // MARK: - Determine Overall Health
    private func determineOverallHealth(topResult: ClassificationResult, confidence: Float) -> PlantHealth {
        if topResult.identifier.lowercased() == "saludable" {
            return confidence >= 0.7 ? .healthy : .fair
        }
        
        if topResult.identifier.lowercased() == "broca" || topResult.identifier.lowercased() == "roya" {
            return confidence >= 0.7 ? .poor : .fair
        }
        
        // For nutritional deficiencies
        switch topResult.severity {
        case .severe:
            return .poor
        case .moderate:
            return .fair
        case .low:
            return .fair
        }
    }
    
    // MARK: - Delete Diagnosis
    func deleteDiagnosis(_ diagnosis: Diagnosis) {
        diagnoses.removeAll { $0.id == diagnosis.id }
        saveDiagnoses()
    }
    
    // MARK: - Export Diagnosis
    func exportDiagnosis(_ diagnosis: Diagnosis) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "es_MX")
        
        var export = """
        REPORTE DE DIAGNÓSTICO DE PLANTAS
        =====================================
        
        INFORMACIÓN GENERAL
        -------------------
        Parcela: \(diagnosis.parcelName)
        Planta: \(diagnosis.plantNumber)
        Técnico: \(diagnosis.technicianName)
        Fecha: \(dateFormatter.string(from: diagnosis.date))
        Estado General: \(diagnosis.overallHealth.rawValue)
        
        DIAGNÓSTICO
        -----------
        \(diagnosis.diagnosis)
        
        """
        
        if !diagnosis.nutritionalDeficiencies.isEmpty {
            export += """
            
            DEFICIENCIAS NUTRICIONALES DETECTADAS
            --------------------------------------
            """
            
            for (index, deficiency) in diagnosis.nutritionalDeficiencies.enumerated() {
                export += """
                
                
                \(index + 1). \(deficiency.nutrient.rawValue) (\(deficiency.nutrient.symbol))
                   Severidad: \(deficiency.severity.rawValue)
                   Plantas afectadas: \(deficiency.plantsAffected) (\(String(format: "%.1f", deficiency.percentage))%)
                   
                   Recomendaciones:
                   \(deficiency.recommendations)
                """
            }
        }
        
        if let notes = diagnosis.notes, !notes.isEmpty {
            export += """
            
            
            NOTAS ADICIONALES
            ------------------
            \(notes)
            """
        }
        
        export += """
        
        
        ---
        Reporte generado por Brew App
        \(Date())
        """
        
        return export
    }
    
    // MARK: - Storage
    private func saveDiagnoses() {
        if let encoded = try? JSONEncoder().encode(diagnoses) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadDiagnoses() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Diagnosis].self, from: data) {
            diagnoses = decoded
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Photo Analysis Request
struct PhotoAnalysisRequest {
    let imageData: Data
    let parcelName: String
    let plantNumber: String
    let technicianName: String
    let totalPlants: Int
    let additionalNotes: String?
}
