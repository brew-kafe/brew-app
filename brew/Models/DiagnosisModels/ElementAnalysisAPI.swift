//
//  ElementAnalysisAPI.swift
//  brew
//
//  Created by toño on 21/10/25.
//
import Foundation

struct ElementAnalysisAPI: Codable {
    let element: String
    let percentage: Double
    let detection_state: String
    let deficiency_level: String?
    let recommendations: [String]
}
