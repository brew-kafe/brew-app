//
//  DiagnosisCreateAPIRequest.swift
//  brew
//
//  Created by toño on 21/10/25.
//

import Foundation

struct DiagnosisCreateAPIRequest: Codable {
    let user_id: String
    let parcel_name: String
    let plant_number: String?
    let technician_name: String
    let primary_deficiency: String
    let deficiency_element: String
    let detection_state: String
    let ai_confidence: Double?
    let ai_description: String?
    let ai_recommendations: [String]
    let all_elements: [ElementAnalysisAPI]
    let photo_urls: [String]
    let notes: String?
}
