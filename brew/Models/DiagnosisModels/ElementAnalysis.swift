//
//  ElementAnalysis.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct ElementAnalysis: Codable, Identifiable {
    let id = UUID()
    let element: String
    let percentage: Double
    let detectionState: DetectionState
    let deficiencyLevel: String?
    let recommendations: [String]

    enum CodingKeys: String, CodingKey {
        case element, percentage
        case detectionState = "detection_state"
        case deficiencyLevel = "deficiency_level"
        case recommendations  
    }
}
