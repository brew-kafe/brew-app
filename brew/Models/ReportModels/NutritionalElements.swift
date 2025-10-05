//
//  NutritionalElements.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import SwiftUI

// MARK: - Nutritional Element Information
struct NutritionalElement {
    let name: String
    let symbol: String
    let description: String
    let idealRange: ClosedRange<Double>
    let deficiencySymptoms: String
    let excessSymptoms: String
    let color: Color
    
    static let allElements: [NutritionalElement] = [
        NutritionalElement(
            name: "Nitrógeno",
            symbol: "N",
            description: "Esencial para el crecimiento vegetativo y la síntesis de proteínas",
            idealRange: 2.8...3.5,
            deficiencySymptoms: "Hojas amarillentas, crecimiento lento, baja producción",
            excessSymptoms: "Crecimiento vegetativo excesivo, retraso en floración",
            color: .green
        ),
        NutritionalElement(
            name: "Fósforo",
            symbol: "P",
            description: "Importante para el desarrollo de raíces y floración",
            idealRange: 0.12...0.18,
            deficiencySymptoms: "Hojas púrpuras, desarrollo radicular pobre",
            excessSymptoms: "Interferencia con absorción de micronutrientes",
            color: .orange
        ),
        NutritionalElement(
            name: "Potasio",
            symbol: "K",
            description: "Regula la apertura de estomas y resistencia a enfermedades",
            idealRange: 1.8...2.5,
            deficiencySymptoms: "Bordes de hojas quemados, frutos pequeños",
            excessSymptoms: "Bloqueo de absorción de magnesio y calcio",
            color: .blue
        ),
        NutritionalElement(
            name: "Zinc",
            symbol: "Zn",
            description: "Cofactor enzimático, síntesis de auxinas",
            idealRange: 8...25,
            deficiencySymptoms: "Hojas pequeñas, internudos cortos, clorosis",
            excessSymptoms: "Toxicidad, interferencia con hierro",
            color: .gray
        ),
        NutritionalElement(
            name: "Magnesio",
            symbol: "Mg",
            description: "Centro de la molécula de clorofila",
            idealRange: 0.25...0.35,
            deficiencySymptoms: "Clorosis intervenal en hojas maduras",
            excessSymptoms: "Bloqueo de absorción de potasio",
            color: .mint
        ),
        NutritionalElement(
            name: "Hierro",
            symbol: "Fe",
            description: "Síntesis de clorofila y respiración celular",
            idealRange: 50...150,
            deficiencySymptoms: "Clorosis intervenal en hojas jóvenes",
            excessSymptoms: "Toxicidad, manchas necróticas",
            color: .brown
        ),
        NutritionalElement(
            name: "Azufre",
            symbol: "S",
            description: "Componente de aminoácidos y proteínas",
            idealRange: 0.15...0.25,
            deficiencySymptoms: "Clorosis generalizada, similar al nitrógeno",
            excessSymptoms: "Acidificación del suelo",
            color: .yellow
        ),
        NutritionalElement(
            name: "Manganeso",
            symbol: "Mn",
            description: "Activador enzimático, fotosíntesis",
            idealRange: 30...150,
            deficiencySymptoms: "Clorosis intervenal, manchas necróticas",
            excessSymptoms: "Toxicidad, puntos marrones en hojas",
            color: .purple
        ),
        NutritionalElement(
            name: "Boro",
            symbol: "B",
            description: "Estructura de paredes celulares, polinización",
            idealRange: 20...60,
            deficiencySymptoms: "Deformación de hojas, muerte de puntas de crecimiento",
            excessSymptoms: "Quemadura de bordes de hojas",
            color: .pink
        )
    ]
    
    // Helper methods
    static func getElement(byName name: String) -> NutritionalElement? {
        return allElements.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getElement(bySymbol symbol: String) -> NutritionalElement? {
        return allElements.first { $0.symbol.lowercased() == symbol.lowercased() }
    }
    
    func evaluateLevel(_ value: Double) -> NutritionalLevel {
        if idealRange.contains(value) {
            return .optimal
        } else if value < idealRange.lowerBound {
            return .deficient
        } else {
            return .excessive
        }
    }
}

// MARK: - Nutritional Level Evaluation
enum NutritionalLevel: String, CaseIterable {
    case deficient = "Deficiente"
    case optimal = "Óptimo"
    case excessive = "Excesivo"
    
    var color: Color {
        switch self {
        case .deficient: return .red
        case .optimal: return .green
        case .excessive: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .deficient: return "arrow.down.circle.fill"
        case .optimal: return "checkmark.circle.fill"
        case .excessive: return "arrow.up.circle.fill"
        }
    }
}
