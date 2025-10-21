//
//  DetectionStateResponse.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct DetectionStateInfo: Codable, Hashable {
    let label: String
    let color: String
    let description: String
}

struct DetectionStateResponse: Codable {
    let states: [String: DetectionStateInfo]
}

enum DetectionState: String, Codable, CaseIterable {
    case danger = "danger"
    case moderate = "moderate"
    case optimal = "optimal"
    
    var displayName: String {
        switch self {
        case .danger: return "Crítico"
        case .moderate: return "Moderado"
        case .optimal: return "Óptimo"
        }
    }
    
    var color: String {
        switch self {
        case .danger: return "#FF4444"
        case .moderate: return "#FF8800"
        case .optimal: return "#44AA44"
        }
    }
}
