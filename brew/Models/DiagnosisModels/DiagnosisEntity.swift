//
//  DiagnosisEntity.swift
//  brew
//
//  Created by toño on 08/10/25.
//

import Foundation
import SwiftData

@Model
class DiagnosisEntity {
    @Attribute(.unique) var id: UUID
    var parcelName: String
    var plantNumber: String?
    var technicianName: String
    var primaryDeficiency: String
    var deficiencyElement: String
    var detectionState: String
    var aiConfidence: Double
    var aiDescription: String
    var diagnosisDate: Date
    var createdAt: Date
    
    // Stored as JSON Data
    var aiRecommendationsData: Data?
    var allElementsData: Data?
    var photoURLsData: Data?
    
    init(
        id: UUID = UUID(),
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String,
        primaryDeficiency: String,
        deficiencyElement: String,
        detectionState: String,
        aiConfidence: Double = 0.0,
        aiDescription: String = "",
        aiRecommendations: [String] = [],
        allElements: [ElementAnalysis] = [],
        photoURLs: [String] = [],
        diagnosisDate: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.parcelName = parcelName
        self.plantNumber = plantNumber
        self.technicianName = technicianName
        self.primaryDeficiency = primaryDeficiency
        self.deficiencyElement = deficiencyElement
        self.detectionState = detectionState
        self.aiConfidence = aiConfidence
        self.aiDescription = aiDescription
        self.diagnosisDate = diagnosisDate
        self.createdAt = createdAt
        
        // Encode to Data
        self.aiRecommendationsData = try? JSONEncoder().encode(aiRecommendations)
        self.allElementsData = try? JSONEncoder().encode(allElements)
        self.photoURLsData = try? JSONEncoder().encode(photoURLs)
    }
    
    // MARK: - Computed Properties for Decoding
    
    var aiRecommendations: [String] {
        get {
            guard let data = aiRecommendationsData,
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            aiRecommendationsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var allElements: [ElementAnalysis] {
        get {
            guard let data = allElementsData,
                  let decoded = try? JSONDecoder().decode([ElementAnalysis].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            allElementsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var photoURLs: [String] {
        get {
            guard let data = photoURLsData,
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            photoURLsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// Computed property to get DetectionState enum from string
    var detectionStateEnum: DetectionState? {
        return DetectionState(rawValue: detectionState)
    }
}
