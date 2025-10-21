//
//  AIDiagnosisDataService.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import Foundation
import SwiftData

@available(iOS 18.1, macOS 15.1, *)
@Model
class AIDiagnosisEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var detailedDescription: String
    var primaryDeficiency: String
    var deficiencyElement: String
    var detectionState: String
    var confidencePercentage: Double
    var parcelName: String
    var technicianName: String
    var additionalNotes: String?
    var createdAt: Date
    var diagnosisDate: Date
    
    // Stored as JSON strings for complex data
    var recommendationsData: Data?
    var elementAnalysisData: Data?
    var immediateActionsData: Data?
    var longTermCareData: Data?
    var photoUrlsData: Data?
    
    var expectedRecoveryTime: String
    var riskAssessment: String
    
    init(
        id: UUID = UUID(),
        title: String,
        detailedDescription: String,
        primaryDeficiency: String,
        deficiencyElement: String,
        detectionState: String,
        confidencePercentage: Double,
        parcelName: String,
        technicianName: String,
        additionalNotes: String? = nil,
        expectedRecoveryTime: String,
        riskAssessment: String,
        recommendations: [String] = [],
        elementAnalysis: [ElementAnalysisAI] = [],
        immediateActions: [String] = [],
        longTermCare: [String] = [],
        photoUrls: [String] = [],
        createdAt: Date = Date(),
        diagnosisDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detailedDescription = detailedDescription
        self.primaryDeficiency = primaryDeficiency
        self.deficiencyElement = deficiencyElement
        self.detectionState = detectionState
        self.confidencePercentage = confidencePercentage
        self.parcelName = parcelName
        self.technicianName = technicianName
        self.additionalNotes = additionalNotes
        self.expectedRecoveryTime = expectedRecoveryTime
        self.riskAssessment = riskAssessment
        self.createdAt = createdAt
        self.diagnosisDate = diagnosisDate
        
        // Encode complex data as JSON
        self.recommendationsData = try? JSONEncoder().encode(recommendations)
        self.elementAnalysisData = try? JSONEncoder().encode(elementAnalysis)
        self.immediateActionsData = try? JSONEncoder().encode(immediateActions)
        self.longTermCareData = try? JSONEncoder().encode(longTermCare)
        self.photoUrlsData = try? JSONEncoder().encode(photoUrls)
    }
    
    // MARK: - Computed Properties for decoding JSON data
    
    var recommendations: [String] {
        guard let data = recommendationsData,
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return decoded
    }
    
    var elementAnalysis: [ElementAnalysisAI] {
        guard let data = elementAnalysisData,
              let decoded = try? JSONDecoder().decode([ElementAnalysisAI].self, from: data) else {
            return []
        }
        return decoded
    }
    
    var immediateActions: [String] {
        guard let data = immediateActionsData,
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return decoded
    }
    
    var longTermCare: [String] {
        guard let data = longTermCareData,
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return decoded
    }
    
    var photoUrls: [String] {
        guard let data = photoUrlsData,
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return decoded
    }
}

// MARK: - AI Diagnosis Data Service

@available(iOS 18.1, macOS 15.1, *)
@MainActor
class AIDiagnosisDataService: ObservableObject {
    static let shared = AIDiagnosisDataService()
    
    @Published var diagnoses: [AIDiagnosisEntity] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var modelContext: ModelContext?
    
    private init() {
        setupModelContext()
        loadDiagnoses()
    }
    
    private func setupModelContext() {
        do {
            let container = try ModelContainer(for: AIDiagnosisEntity.self)
            modelContext = ModelContext(container)
        } catch {
            print("Failed to create ModelContainer for AI Diagnoses: \(error)")
            self.error = error
        }
    }
    
    // MARK: - CRUD Operations
    
    func saveDiagnosis(_ diagnosis: AIGeneratedDiagnosis, parcelName: String, technicianName: String, additionalNotes: String? = nil, photoUrls: [String] = []) throws {
        guard let context = modelContext else {
            throw AIDiagnosisError.contextNotAvailable
        }
        
        let entity = AIDiagnosisEntity(
            title: diagnosis.title,
            detailedDescription: diagnosis.detailedDescription,
            primaryDeficiency: diagnosis.primaryDeficiency,
            deficiencyElement: diagnosis.deficiencyElement,
            detectionState: diagnosis.detectionState,
            confidencePercentage: diagnosis.confidencePercentage,
            parcelName: parcelName,
            technicianName: technicianName,
            additionalNotes: additionalNotes,
            expectedRecoveryTime: diagnosis.expectedRecoveryTime,
            riskAssessment: diagnosis.riskAssessment,
            recommendations: diagnosis.recommendations,
            elementAnalysis: diagnosis.elementAnalysis,
            immediateActions: diagnosis.immediateActions,
            longTermCare: diagnosis.longTermCare,
            photoUrls: photoUrls
        )
        
        context.insert(entity)
        
        do {
            try context.save()
            loadDiagnoses() // Refresh the list
        } catch {
            throw AIDiagnosisError.saveFailed(error)
        }
    }
    
    func loadDiagnoses() {
        guard let context = modelContext else { return }
        
        isLoading = true
        
        do {
            let descriptor = FetchDescriptor<AIDiagnosisEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            diagnoses = try context.fetch(descriptor)
        } catch {
            self.error = error
            print("Failed to load AI diagnoses: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteDiagnosis(_ diagnosis: AIDiagnosisEntity) throws {
        guard let context = modelContext else {
            throw AIDiagnosisError.contextNotAvailable
        }
        
        context.delete(diagnosis)
        
        do {
            try context.save()
            loadDiagnoses()
        } catch {
            throw AIDiagnosisError.deleteFailed(error)
        }
    }
    
    func getDiagnosis(by id: UUID) -> AIDiagnosisEntity? {
        return diagnoses.first { $0.id == id }
    }
    
    // MARK: - Statistics
    
    var totalDiagnoses: Int {
        diagnoses.count
    }
    
    var averageConfidence: Double {
        guard !diagnoses.isEmpty else { return 0 }
        let total = diagnoses.reduce(0) { $0 + $1.confidencePercentage }
        return total / Double(diagnoses.count)
    }
    
    var mostCommonDeficiency: String? {
        let deficiencies = diagnoses.map { $0.primaryDeficiency }
        let grouped = Dictionary(grouping: deficiencies, by: { $0 })
        return grouped.max(by: { $0.value.count < $1.value.count })?.key
    }
    
    func diagnosesForParcel(_ parcelName: String) -> [AIDiagnosisEntity] {
        return diagnoses.filter { $0.parcelName.lowercased() == parcelName.lowercased() }
    }
    
    func diagnosesForTechnician(_ technicianName: String) -> [AIDiagnosisEntity] {
        return diagnoses.filter { $0.technicianName.lowercased() == technicianName.lowercased() }
    }
}

// MARK: - Errors

enum AIDiagnosisError: LocalizedError {
    case contextNotAvailable
    case saveFailed(Error)
    case deleteFailed(Error)
    case loadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return "Database context not available"
        case .saveFailed(let error):
            return "Failed to save diagnosis: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete diagnosis: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load diagnoses: \(error.localizedDescription)"
        }
    }
}

// MARK: - Extensions

@available(iOS 18.1, macOS 15.1, *)
extension AIGeneratedDiagnosis {
    func toEntity(parcelName: String, technicianName: String, additionalNotes: String? = nil, photoUrls: [String] = []) -> AIDiagnosisEntity {
        return AIDiagnosisEntity(
            title: title,
            detailedDescription: detailedDescription,
            primaryDeficiency: primaryDeficiency,
            deficiencyElement: deficiencyElement,
            detectionState: detectionState,
            confidencePercentage: confidencePercentage,
            parcelName: parcelName,
            technicianName: technicianName,
            additionalNotes: additionalNotes,
            expectedRecoveryTime: expectedRecoveryTime,
            riskAssessment: riskAssessment,
            recommendations: recommendations,
            elementAnalysis: elementAnalysis,
            immediateActions: immediateActions,
            longTermCare: longTermCare,
            photoUrls: photoUrls
        )
    }
}

@available(iOS 18.1, macOS 15.1, *)
extension AIDiagnosisEntity {
    func toAIGeneratedDiagnosis() -> AIGeneratedDiagnosis {
        return AIGeneratedDiagnosis(
            title: title,
            detailedDescription: detailedDescription,
            primaryDeficiency: primaryDeficiency,
            deficiencyElement: deficiencyElement,
            detectionState: detectionState,
            confidencePercentage: confidencePercentage,
            recommendations: recommendations,
            elementAnalysis: elementAnalysis,
            immediateActions: immediateActions,
            longTermCare: longTermCare,
            expectedRecoveryTime: expectedRecoveryTime,
            riskAssessment: riskAssessment
        )
    }
}