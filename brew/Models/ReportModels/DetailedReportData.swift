//
//  DetailedReportData.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import SwiftUI

// MARK: - Main Report Data Model
struct DetailedReportData: Identifiable, Codable {
    let id: String
    let parcelName: String
    let plantNumber: String
    let diagnosis: String
    let statusIcon: String
    let statusColor: String // We'll handle Color conversion separately
    let timestamp: String
    let technicianName: String
    let nutritionalData: [NutritionalData]
    let soilData: SoilData
    let aiAnalysisResults: [AIAnalysisResult]
    let manualObservations: String
    let photos: [PhotoData]
    
    // Helper computed property for SwiftUI Color
    var statusSwiftUIColor: Color {
        switch statusColor.lowercased() {
        case "red": return .red
        case "yellow": return .yellow
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        default: return .gray
        }
    }
    
    // Computed property for radar chart datasets
    var radarDataSets: [RadarChartDataSet] {
        var dataSets: [RadarChartDataSet] = []
        
        // Add nutritional data
        if !nutritionalData.isEmpty {
            dataSets.append(RadarChartDataSet.fromNutritionalData(nutritionalData))
        }
        
        // Add soil data
        dataSets.append(RadarChartDataSet.fromSoilData(soilData))
        
        // Add AI analysis data
        if !aiAnalysisResults.isEmpty {
            dataSets.append(RadarChartDataSet.fromAIAnalysis(aiAnalysisResults))
        }
        
        return dataSets
    }
}

// MARK: - Nutritional Data Model
struct NutritionalData: Identifiable, Codable {
    let id = UUID()
    let nutrient: String
    let symptomsPercentage: Double
    let weightingValue: Int
    
    enum CodingKeys: String, CodingKey {
        case nutrient, symptomsPercentage, weightingValue
    }
    
    // Helper computed property to get symbol from full name
    var symbol: String {
        switch nutrient {
        case "Nitrógeno": return "N"
        case "Fósforo": return "P"
        case "Potasio": return "K"
        case "Zinc": return "Zn"
        case "Magnesio": return "Mg"
        case "Hierro": return "Fe"
        case "Azufre": return "S"
        case "Manganeso": return "Mn"
        case "Boro": return "B"
        default: return String(nutrient.prefix(2))
        }
    }
}

// MARK: - Soil Data Model
struct SoilData: Codable {
    let structure: String
    let color: String
    let texture: String
    let ph: Double
    let organicMatter: Double
    let overallScore: Int
}

// MARK: - AI Analysis Result Model
struct AIAnalysisResult: Identifiable, Codable {
    let id = UUID()
    let condition: String
    let confidence: Double
    
    enum CodingKeys: String, CodingKey {
        case condition, confidence
    }
}

// MARK: - Photo Data Model
struct PhotoData: Identifiable, Codable {
    let id: String
    let url: String
    let description: String
}

// MARK: - Sample Data
extension DetailedReportData {
    static let sample = DetailedReportData(
        id: "RPT001",
        parcelName: "Parcela Los Cafetos",
        plantNumber: "Planta 102",
        diagnosis: "Deficiencia nutricional detectada en hojas",
        statusIcon: "leaf.circle.fill",
        statusColor: "red",
        timestamp: "10:30am | Oct 4, 2024",
        technicianName: "María García",
        nutritionalData: [
            NutritionalData(nutrient: "Nitrógeno", symptomsPercentage: 25.0, weightingValue: 3),
            NutritionalData(nutrient: "Fósforo", symptomsPercentage: 15.0, weightingValue: 4),
            NutritionalData(nutrient: "Potasio", symptomsPercentage: 35.0, weightingValue: 2),
            NutritionalData(nutrient: "Zinc", symptomsPercentage: 22.0, weightingValue: 4),
            NutritionalData(nutrient: "Magnesio", symptomsPercentage: 10.0, weightingValue: 5),
            NutritionalData(nutrient: "Hierro", symptomsPercentage: 28.0, weightingValue: 3),
            NutritionalData(nutrient: "Azufre", symptomsPercentage: 32.0, weightingValue: 2),
            NutritionalData(nutrient: "Manganeso", symptomsPercentage: 18.0, weightingValue: 4),
            NutritionalData(nutrient: "Boro", symptomsPercentage: 24.0, weightingValue: 3)
        ],
        soilData: SoilData(
            structure: "Granular",
            color: "Café claro",
            texture: "Franco limoso",
            ph: 6.5,
            organicMatter: 3.2,
            overallScore: 4
        ),
        aiAnalysisResults: [
            AIAnalysisResult(condition: "Deficiencia de Nitrógeno", confidence: 0.89),
            AIAnalysisResult(condition: "Posible enfermedad fúngica", confidence: 0.67)
        ],
        manualObservations: "Se observan manchas amarillentas en las hojas inferiores, típicas de deficiencia de nitrógeno. Recomendado aplicar fertilizante rico en nitrógeno en la próxima semana.",
        photos: [
            PhotoData(id: "1", url: "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800", description: "Hojas con deficiencia nutricional"),
            PhotoData(id: "2", url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800", description: "Vista general de la planta"),
            PhotoData(id: "3", url: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800", description: "Detalle del suelo")
        ]
    )
    
    static let sampleHealthy = DetailedReportData(
        id: "RPT002",
        parcelName: "Parcela El Mirador",
        plantNumber: "Planta 245",
        diagnosis: "Planta en excelente estado de salud",
        statusIcon: "checkmark.circle.fill",
        statusColor: "green",
        timestamp: "2:15pm | Oct 4, 2024",
        technicianName: "Carlos Mendez",
        nutritionalData: [
            NutritionalData(nutrient: "Nitrógeno", symptomsPercentage: 5.0, weightingValue: 5),
            NutritionalData(nutrient: "Fósforo", symptomsPercentage: 3.0, weightingValue: 5),
            NutritionalData(nutrient: "Potasio", symptomsPercentage: 2.0, weightingValue: 5),
            NutritionalData(nutrient: "Zinc", symptomsPercentage: 4.0, weightingValue: 5),
            NutritionalData(nutrient: "Magnesio", symptomsPercentage: 1.0, weightingValue: 5),
            NutritionalData(nutrient: "Hierro", symptomsPercentage: 6.0, weightingValue: 4),
            NutritionalData(nutrient: "Azufre", symptomsPercentage: 7.0, weightingValue: 4),
            NutritionalData(nutrient: "Manganeso", symptomsPercentage: 3.5, weightingValue: 5),
            NutritionalData(nutrient: "Boro", symptomsPercentage: 4.5, weightingValue: 4)
        ],
        soilData: SoilData(
            structure: "Grumosa",
            color: "Café oscuro",
            texture: "Franco",
            ph: 6.8,
            organicMatter: 4.1,
            overallScore: 5
        ),
        aiAnalysisResults: [
            AIAnalysisResult(condition: "Planta saludable", confidence: 0.95)
        ],
        manualObservations: "Planta en perfecto estado. Crecimiento vigoroso y hojas de color verde intenso. Mantener el programa actual de fertilización.",
        photos: [
            PhotoData(id: "4", url: "https://images.unsplash.com/photo-1587736797647-bc09e8ddc472?w=800", description: "Hojas saludables"),
            PhotoData(id: "5", url: "https://images.unsplash.com/photo-1587736800318-9249e4b12c29?w=800", description: "Planta completa")
        ]
    )
}
