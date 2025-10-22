//
//  DetectionState.swift
//  brew
//
//  Created by AI Assistant on 22/10/25.
//

import Foundation
import SwiftUI

/// Enum representing the detection state for plant health diagnosis
enum DetectionState: String, Codable, CaseIterable {
    case danger = "danger"
    case moderate = "moderate" 
    case optimal = "optimal"
    
    /// Display name for the detection state
    var displayName: String {
        switch self {
        case .danger:
            return "Crítico"
        case .moderate:
            return "Moderado"
        case .optimal:
            return "Óptimo"
        }
    }
    
    /// Color associated with the detection state
    var color: Color {
        switch self {
        case .danger:
            return .red
        case .moderate:
            return .orange
        case .optimal:
            return .green
        }
    }
    
    /// Icon associated with the detection state
    var icon: String {
        switch self {
        case .danger:
            return "exclamationmark.triangle.fill"
        case .moderate:
            return "exclamationmark.circle.fill"
        case .optimal:
            return "checkmark.circle.fill"
        }
    }
    
    /// Create DetectionState from confidence level
    static func fromConfidence(_ confidence: Float) -> DetectionState {
        switch confidence {
        case 0.8...1.0:
            return .danger
        case 0.5..<0.8:
            return .moderate
        default:
            return .optimal
        }
    }
}