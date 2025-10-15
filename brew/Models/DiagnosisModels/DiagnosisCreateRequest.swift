//
//  DiagnosisCreateRequest.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct DiagnosisCreateRequest: Codable {
    let parcelName: String
    let plantNumber: String
    let technicianName: String
    let aiAnalysis: AIPlantDiagnosis
    let photoUrls: [String]
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case parcelName = "parcel_name"
        case plantNumber = "plant_number"
        case technicianName = "technician_name"
        case aiAnalysis = "ai_analysis"
        case photoUrls = "photo_urls"
        case notes
    }
}
