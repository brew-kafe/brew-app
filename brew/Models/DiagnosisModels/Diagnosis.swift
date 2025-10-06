//
//  Diagnosis.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import SwiftUI

// MARK: - Diagnosis Model
struct Diagnosis: Identifiable, Codable {
    let id: UUID
    let parcelName: String
    let plantNumber: String
    let technicianName: String
    let diagnosis: String
    let date: Date
    let imageData: Data?
    let nutritionalDeficiencies: [NutritionalDeficiency]
    let overallHealth: PlantHealth
    let notes: String?
    
    init(
        id: UUID = UUID(),
        parcelName: String,
        plantNumber: String,
        technicianName: String,
        diagnosis: String,
        date: Date = Date(),
        imageData: Data? = nil,
        nutritionalDeficiencies: [NutritionalDeficiency] = [],
        overallHealth: PlantHealth = .unknown,
        notes: String? = nil
    ) {
        self.id = id
        self.parcelName = parcelName
        self.plantNumber = plantNumber
        self.technicianName = technicianName
        self.diagnosis = diagnosis
        self.date = date
        self.imageData = imageData
        self.nutritionalDeficiencies = nutritionalDeficiencies
        self.overallHealth = overallHealth
        self.notes = notes
    }
}

// MARK: - Plant Health Status
enum PlantHealth: String, Codable, CaseIterable {
    case excellent = "Excelente"
    case good = "Buena"
    case fair = "Regular"
    case poor = "Pobre"
    case critical = "Crítica"
    case unknown = "Sin analizar"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return Color(red: 0.5, green: 0.8, blue: 0.3)
        case .fair: return .yellow
        case .poor: return .orange
        case .critical: return .red
        case .unknown: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "checkmark.seal.fill"
        case .good: return "checkmark.circle.fill"
        case .fair: return "exclamationmark.circle.fill"
        case .poor: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Nutritional Deficiency
struct NutritionalDeficiency: Identifiable, Codable {
    let id: UUID
    let nutrient: NutrientType
    let severity: DeficiencySeverity
    let plantsAffected: Int
    let percentage: Double
    let recommendations: String
    
    init(
        id: UUID = UUID(),
        nutrient: NutrientType,
        severity: DeficiencySeverity,
        plantsAffected: Int,
        percentage: Double,
        recommendations: String
    ) {
        self.id = id
        self.nutrient = nutrient
        self.severity = severity
        self.plantsAffected = plantsAffected
        self.percentage = percentage
        self.recommendations = recommendations
    }
}

// MARK: - Nutrient Types
enum NutrientType: String, Codable, CaseIterable {
    case nitrogen = "Nitrógeno"
    case phosphorus = "Fósforo"
    case potassium = "Potasio"
    case zinc = "Zinc"
    case magnesium = "Magnesio"
    case iron = "Hierro"
    case sulfur = "Azufre"
    case manganese = "Manganeso"
    case boron = "Boro"
    case calcium = "Calcio"
    case copper = "Cobre"
    
    var symbol: String {
        switch self {
        case .nitrogen: return "N"
        case .phosphorus: return "P"
        case .potassium: return "K"
        case .zinc: return "Zn"
        case .magnesium: return "Mg"
        case .iron: return "Fe"
        case .sulfur: return "S"
        case .manganese: return "Mn"
        case .boron: return "B"
        case .calcium: return "Ca"
        case .copper: return "Cu"
        }
    }
}

// MARK: - Deficiency Severity
enum DeficiencySeverity: String, Codable, CaseIterable {
    case mild = "Leve"
    case moderate = "Moderada"
    case severe = "Severa"
    case critical = "Crítica"
    
    var color: Color {
        switch self {
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return Color(red: 0.9, green: 0.4, blue: 0.2)
        case .critical: return .red
        }
    }
}

// MARK: - Photo Analysis Request
struct PhotoAnalysisRequest {
    let imageData: Data
    let parcelName: String
    let plantNumber: String
    let technicianName: String
    let totalPlants: Int
    let additionalNotes: String?
}
