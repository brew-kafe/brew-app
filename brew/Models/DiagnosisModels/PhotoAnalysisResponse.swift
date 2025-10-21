//
//  PhotoAnalysisResponse.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct PhotoAnalysisResponse: Codable {
    let photoId: String
    let diagnosisResult: AIPlantDiagnosis
    let photoUrl: String
    let analysisTimestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case photoId = "photo_id"
        case diagnosisResult = "diagnosis_result"
        case photoUrl = "photo_url"
        case analysisTimestamp = "analysis_timestamp"
    }
}
