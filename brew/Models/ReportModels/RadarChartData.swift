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
    case soil = "Suelo" 
    case health = "Salud"
    case growth = "Crecimiento"
    
    var icon: String {
        switch self {
        case .nutritional: return "leaf.fill"
        case .soil: return "globe.americas.fill"
        case .health: return "cross.fill"
        case .growth: return "arrow.up.right"
        }
    }
    
    var color: Color {
        switch self {
        case .nutritional: return .green
        case .soil: return .brown
        case .health: return .blue
        case .growth: return .purple
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
    
    static func fromSoilData(_ data: SoilData) -> RadarChartDataSet {
        let dataPoints = [
            RadarDataPoint(label: "pH", value: normalizedPH(data.ph), maxValue: 1.0),
            RadarDataPoint(label: "Materia Orgánica", value: data.organicMatter, maxValue: 10.0),
            RadarDataPoint(label: "Estructura", value: structureScore(data.structure), maxValue: 1.0),
            RadarDataPoint(label: "Textura", value: textureScore(data.texture), maxValue: 1.0),
            RadarDataPoint(label: "Puntuación", value: Double(data.overallScore), maxValue: 5.0)
        ]
        
        let overallScore = dataPoints.reduce(0.0) { $0 + $1.normalizedValue } / Double(dataPoints.count)
        
        return RadarChartDataSet(
            type: .soil,
            dataPoints: dataPoints,
            overallScore: overallScore
        )
    }
    
    static func fromAIAnalysis(_ results: [AIAnalysisResult]) -> RadarChartDataSet {
        let dataPoints = results.map { result in
            RadarDataPoint(
                label: result.condition,
                value: result.confidence,
                maxValue: 1.0
            )
        }
        
        let overallScore = dataPoints.isEmpty ? 0.0 : 
            dataPoints.reduce(0.0) { $0 + $1.normalizedValue } / Double(dataPoints.count)
        
        return RadarChartDataSet(
            type: .health,
            dataPoints: dataPoints,
            overallScore: overallScore
        )
    }
    
    // Helper functions for soil data conversion
    private static func normalizedPH(_ ph: Double) -> Double {
        // Ideal pH range for coffee is 6.0-7.0
        let idealPH = 6.5
        let deviation = abs(ph - idealPH)
        return max(0.0, 1.0 - (deviation / 2.0)) // Max deviation of 2.0 gives score of 0
    }
    
    private static func structureScore(_ structure: String) -> Double {
        switch structure.lowercased() {
        case "granular", "grumosa": return 1.0
        case "blocosa", "prismática": return 0.7
        case "laminar": return 0.4
        default: return 0.5
        }
    }
    
    private static func textureScore(_ texture: String) -> Double {
        switch texture.lowercased() {
        case "franco", "franco limoso": return 1.0
        case "franco arenoso", "franco arcilloso": return 0.8
        case "arenoso": return 0.6
        case "arcilloso": return 0.4
        default: return 0.5
        }
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
    
    static let soilSample = RadarChartDataSet(
        type: .soil,
        dataPoints: [
            RadarDataPoint(label: "pH", value: 6.5, maxValue: 8.0),
            RadarDataPoint(label: "Materia Orgánica", value: 3.2, maxValue: 10.0),
            RadarDataPoint(label: "Estructura", value: 0.9, maxValue: 1.0),
            RadarDataPoint(label: "Textura", value: 0.8, maxValue: 1.0),
            RadarDataPoint(label: "Drenaje", value: 0.7, maxValue: 1.0)
        ],
        overallScore: 0.72
    )
    
    static let healthSample = RadarChartDataSet(
        type: .health,
        dataPoints: [
            RadarDataPoint(label: "Vigor", value: 0.85, maxValue: 1.0),
            RadarDataPoint(label: "Color", value: 0.78, maxValue: 1.0),
            RadarDataPoint(label: "Tamaño", value: 0.82, maxValue: 1.0),
            RadarDataPoint(label: "Densidad", value: 0.90, maxValue: 1.0),
            RadarDataPoint(label: "Resistencia", value: 0.75, maxValue: 1.0)
        ],
        overallScore: 0.82
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

