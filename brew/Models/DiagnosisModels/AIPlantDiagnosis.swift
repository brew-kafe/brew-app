//
//  AIPlantDiagnosis.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct AIPlantDiagnosis: Codable {
    let parcelName: String
    let technicianName: String
    let diagnosisDate: Date
    let primaryDeficiency: String
    let deficiencyElement: String
    let detectionState: DetectionState
    let aiDiagnosisDescription: String
    let aiRecommendations: [String]
    let allElements: [ElementAnalysis]
    let photoUrls: [String]
    let aiConfidence: Double
    let analysisTimestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case parcelName = "parcel_name"
        case technicianName = "technician_name"
        case diagnosisDate = "diagnosis_date"
        case primaryDeficiency = "primary_deficiency"
        case deficiencyElement = "deficiency_element"
        case detectionState = "detection_state"
        case aiDiagnosisDescription = "ai_diagnosis_description"
        case aiRecommendations = "ai_recommendations"
        case allElements = "all_elements"
        case photoUrls = "photo_urls"
        case aiConfidence = "ai_confidence"
        case analysisTimestamp = "analysis_timestamp"
    }
}

