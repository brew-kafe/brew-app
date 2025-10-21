//
//  DiagnosisCreateResponse.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct DiagnosisCreateResponse: Codable {
    let success: Bool
    let message: String
    let diagnosisId: String  // Remove optional - API always returns this
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case diagnosisId = "diagnosis_id"
    }
}
