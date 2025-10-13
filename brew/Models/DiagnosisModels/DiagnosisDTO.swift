//
//  DiagnosisDTO.swift
//  brew
//
//  Created by toño on 08/10/25.
//

import Foundation

struct DiagnosisDTO: Codable, Identifiable, Hashable {
    let id: UUID?
    let parcel_name: String
    let plant_number: String?
    let technician_name: String
    let primary_deficiency: String?
    let deficiency_element: String?
    let detection_state: DetectionState?
    let ai_confidence: Float?
    let ai_description: String?
    let ai_recommendations: [String]?
    let all_elements: [ElementAnalysis]?
    let photo_urls: [String]?
    let overall_health: PlantHealth?
    let notes: String?
    let diagnosis_date: Date
    let created_at: Date?
}

enum PlantHealth: String, Codable {
    case healthy = "Saludable"
    case fair = "Regular"
    case poor = "Deficiente"
}
