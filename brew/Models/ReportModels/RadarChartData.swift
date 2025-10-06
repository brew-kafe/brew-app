//
//  RadarChartData.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import SwiftUI

// MARK: - Radar Chart Data Point
struct RadarDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double // 0.0 to 1.0 (percentage)
    let maxValue: Double // Maximum possible value
    
    // Computed property for normalized value (0.0 to 1.0)
    var normalizedValue: Double {
        guard maxValue > 0 else { return 0.0 }
        return min(max(value / maxValue, 0.0), 1.0)
    }
}

// MARK: - Analysis Type Enum
enum AnalysisType: String, CaseIterable {
    case nutritional = "Nutricional"
    
    var icon: String {
        switch self {
        case .nutritional: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .nutritional: return .green
        }
    }
}

// MARK: - Radar Chart Dataset
struct RadarChartDataSet {
    let type: AnalysisType
    let dataPoints: [RadarDataPoint]
    let overallScore: Double // 0.0 to 1.0
    
    static func fromNutritionalData(_ data: [NutritionalData]) -> RadarChartDataSet {
        let dataPoints = data.map { nutrient in
            RadarDataPoint(
                label: nutrient.nutrient,
                value: max(0, 100 - nutrient.symptomsPercentage), // Convert symptoms to health score
                maxValue: 100.0
            )
        }
        
        let overallScore = dataPoints.isEmpty ? 0.0 :
            dataPoints.reduce(0.0) { $0 + $1.normalizedValue } / Double(dataPoints.count)
        
        return RadarChartDataSet(
            type: .nutritional,
            dataPoints: dataPoints,
            overallScore: overallScore
        )
    }
}

// MARK: - Sample Data
extension RadarChartDataSet {
    static let nutritionalSample = RadarChartDataSet(
        type: .nutritional,
        dataPoints: [
            RadarDataPoint(label: "Nitrógeno", value: 75, maxValue: 100),
            RadarDataPoint(label: "Fósforo", value: 85, maxValue: 100),
            RadarDataPoint(label: "Potasio", value: 65, maxValue: 100),
            RadarDataPoint(label: "Zinc", value: 78, maxValue: 100),
            RadarDataPoint(label: "Magnesio", value: 90, maxValue: 100),
            RadarDataPoint(label: "Hierro", value: 72, maxValue: 100),
            RadarDataPoint(label: "Azufre", value: 68, maxValue: 100),
            RadarDataPoint(label: "Manganeso", value: 82, maxValue: 100),
            RadarDataPoint(label: "Boro", value: 76, maxValue: 100)
        ],
        overallScore: 0.773
    )
}

extension RadarDataPoint {
    var displayLabel: String {
        switch label.lowercased() {
        case "nitrógeno": return "N"
        case "fósforo": return "P"
        case "potasio": return "K"
        case "zinc": return "Zn"
        case "magnesio": return "Mg"
        case "hierro": return "Fe"
        case "azufre": return "S"
        case "manganeso": return "Mn"
        case "boro": return "B"
        default: return label
        }
    }
}
