//
//  AIPlantDiagnosis.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct AIPlantDiagnosis: Codable, Hashable {
    let parcel_name: String
    let technician_name: String
    let diagnosis_date: Date
    let primary_deficiency: String
    let deficiency_element: String
    let detection_state: DetectionState
    let ai_diagnosis_description: String
    let ai_recommendations: [String]
    let all_elements: [ElementAnalysis]
    let photo_urls: [String]
    let ai_confidence: Float
    let analysis_timestamp: Date
}

