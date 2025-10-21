//
//  DiagnosisEntity.swift
//  brew
//
//  Created by toño on 08/10/25.
//

import Foundation
import SwiftData

@Model
final class DiagnosisEntity {
    @Attribute(.unique) var id: UUID
    var parcelName: String
    var plantNumber: String?
    var technicianName: String
    var primaryDeficiency: String
    var deficiencyElement: String
    var detectionState: String
    var aiConfidence: Double?
    var aiDescription: String?
    var aiRecommendations: [String]
    var allElements: [ElementAnalysis]  // Custom struct
    var photoURLs: [String]
    var diagnosisDate: Date
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        parcelName: String,
        plantNumber: String? = nil,
        technicianName: String,
        primaryDeficiency: String,
        deficiencyElement: String,
        detectionState: String,
        aiConfidence: Double? = nil,
        aiDescription: String? = nil,
        aiRecommendations: [String] = [],
        allElements: [ElementAnalysis] = [],
        photoURLs: [String] = [],
        diagnosisDate: Date = .now,
        createdAt: Date = .now
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
        self.aiRecommendations = aiRecommendations
        self.allElements = allElements
        self.photoURLs = photoURLs
        self.diagnosisDate = diagnosisDate
        self.createdAt = createdAt
    }
}

