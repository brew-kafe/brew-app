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
    let date: Date
    let diagnosis: String
    let nutritionalDeficiencies: [NutritionalDeficiency]
    let overallHealth: PlantHealth
    let imageData: Data?
    let notes: String?
    
    init(
        id: UUID = UUID(),
        parcelName: String,
        plantNumber: String,
        technicianName: String,
        date: Date = Date(),
        diagnosis: String,
        nutritionalDeficiencies: [NutritionalDeficiency] = [],
        overallHealth: PlantHealth = .fair,
        imageData: Data? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.parcelName = parcelName
        self.plantNumber = plantNumber
        self.technicianName = technicianName
        self.date = date
        self.diagnosis = diagnosis
        self.nutritionalDeficiencies = nutritionalDeficiencies
        self.overallHealth = overallHealth
        self.imageData = imageData
        self.notes = notes
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

// MARK: - Nutrient Type
enum NutrientType: String, Codable, CaseIterable {
    case nitrogen = "Nitrógeno"
    case phosphorus = "Fósforo"
    case potassium = "Potasio"
    case calcium = "Calcio"
    case magnesium = "Magnesio"
    case iron = "Hierro"
    case manganese = "Manganeso"
    case zinc = "Zinc"
    
    var symbol: String {
        switch self {
        case .nitrogen: return "N"
        case .phosphorus: return "P"
        case .potassium: return "K"
        case .calcium: return "Ca"
        case .magnesium: return "Mg"
        case .iron: return "Fe"
        case .manganese: return "Mn"
        case .zinc: return "Zn"
        }
    }
    
    var color: Color {
        switch self {
        case .nitrogen: return .green
        case .phosphorus: return .purple
        case .potassium: return .blue
        case .calcium: return .orange
        case .magnesium: return .pink
        case .iron: return .red
        case .manganese: return .brown
        case .zinc: return .gray
        }
    }
    
    var description: String {
        switch self {
        case .nitrogen:
            return "Esencial para el crecimiento vegetativo y la producción de clorofila"
        case .phosphorus:
            return "Importante para la formación de raíces y transferencia de energía"
        case .potassium:
            return "Regula procesos fisiológicos y mejora la calidad del fruto"
        case .calcium:
            return "Fundamental para la estructura celular y desarrollo radicular"
        case .magnesium:
            return "Componente central de la clorofila y activador enzimático"
        case .iron:
            return "Esencial para la síntesis de clorofila y procesos respiratorios"
        case .manganese:
            return "Importante para la fotosíntesis y metabolismo del nitrógeno"
        case .zinc:
            return "Regula el crecimiento y desarrollo de las plantas"
        }
    }
}

// MARK: - Deficiency Severity
enum DeficiencySeverity: String, Codable {
    case low = "Leve"
    case moderate = "Moderada"
    case severe = "Severa"
    
    var color: Color {
        switch self {
        case .low: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "exclamationmark.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .severe: return "xmark.octagon.fill"
        }
    }
}

// MARK: - Plant Health
enum PlantHealth: String, Codable {
    case healthy = "Saludable"
    case fair = "Regular"
    case poor = "Deficiente"
    
    var color: Color {
        switch self {
        case .healthy: return .green
        case .fair: return .orange
        case .poor: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .healthy: return "checkmark.seal.fill"
        case .fair: return "exclamationmark.triangle.fill"
        case .poor: return "xmark.shield.fill"
        }
    }
}
