//
//  PhotoAnalysisResponse.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct PhotoAnalysisResponse: Codable, Hashable {
    let photoId: String
    let diagnosisResult: AIPlantDiagnosis
    let photoUrl: String
    let analysisTimestamp: Date
}
