//
//  PhotoAnalysisResponse.swift
//  brew
//
//  Created by toño on 21/10/25.
//

import Foundation

/// Response from the photo analysis API endpoint
struct PhotoAnalysisResponse: Codable {
    let success: Bool
    let message: String
    let primaryDeficiency: String?
    let deficiencyElement: String?
    let detectionState: String
    let aiConfidence: Double?
    let aiDescription: String?
    let aiRecommendations: [String]
    let allElements: [ElementAnalysisAPI]
    let photoUrl: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case primaryDeficiency = "primary_deficiency"
        case deficiencyElement = "deficiency_element"
        case detectionState = "detection_state"
        case aiConfidence = "ai_confidence"
        case aiDescription = "ai_description"
        case aiRecommendations = "ai_recommendations"
        case allElements = "all_elements"
        case photoUrl = "photo_url"
        case error
    }
}

