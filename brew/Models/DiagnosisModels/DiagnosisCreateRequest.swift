//
//  DiagnosisCreateRequest.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct DiagnosisCreateRequest: Codable {
    let parcel_name: String
    let plant_number: String
    let technician_name: String
    let ai_analysis: AIPlantDiagnosis
    let photo_urls: [String]
    let notes: String?
}
