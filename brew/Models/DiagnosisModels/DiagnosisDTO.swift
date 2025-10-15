//
//  DiagnosisDTO.swift
//  brew
//
//  Created by toño on 08/10/25.
//

import Foundation

struct DiagnosisDTO: Codable, Identifiable {
    let id: UUID?
    let parcelName: String
    let plantNumber: String?
    let technicianName: String
    let primaryDeficiency: String?
    let deficiencyElement: String?
    let detectionState: DetectionState?
    let aiConfidence: Double?
    let aiDescription: String?
    let aiRecommendations: [String]?
    let allElements: [ElementAnalysis]?
    let photoUrls: [String]?
    let overallHealth: PlantHealth?
    let notes: String?
    let diagnosisDate: Date
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case parcelName = "parcel_name"
        case plantNumber = "plant_number"
        case technicianName = "technician_name"
        case primaryDeficiency = "primary_deficiency"
        case deficiencyElement = "deficiency_element"
        case detectionState = "detection_state"
        case aiConfidence = "ai_confidence"
        case aiDescription = "ai_description"
        case aiRecommendations = "ai_recommendations"
        case allElements = "all_elements"
        case photoUrls = "photo_urls"
        case overallHealth = "overall_health"
        case notes
        case diagnosisDate = "diagnosis_date"
        case createdAt = "created_at"
    }
}
