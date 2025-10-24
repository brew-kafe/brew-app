//
//  ElementAnalysis.swift
//  brew
//
//  Created by toño on 22/10/25.
//

import Foundation

struct ElementAnalysis: Codable, Hashable, Identifiable {
    var id: String { element } // Use element name as ID
    let element: String
    let percentage: Double
    let detectionState: String
    let deficiencyLevel: String?
    let recommendations: [String]
    
    enum CodingKeys: String, CodingKey {
        case element
        case percentage
        case detectionState = "detection_state"
        case deficiencyLevel = "deficiency_level"
        case recommendations
    }
}
