//
//  ElementAnalysis.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct ElementAnalysis: Codable, Hashable {
    let element: String
    let percentage: Float
    let detection_state: DetectionState
    let deficiency_level: String?
    let recommendations: [String]
}

enum DetectionState: String, Codable {
    case danger
    case moderate
    case optimal
}
