//
//  DiagnosisAPIResponse.swift
//  brew
//
//  Created by toño on 21/10/25.
//
import Foundation

struct DiagnosisAPIResponse: Codable, Identifiable {
    let diagnosis_id: String
    let user_id: String
    let parcel_name: String
    let plant_number: String?
    let technician_name: String
    let primary_deficiency: String
    let deficiency_element: String
    let detection_state: String
    let ai_confidence: Double?
    let ai_description: String?
    let ai_recommendations: [String]
    let all_elements: [ElementAnalysisAPI]
    let photo_urls: [String]
    let diagnosis_date: Date
    let created_at: Date
    
    var id: String { diagnosis_id }
}

enum DiagnosisAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL inválida"
        case .invalidResponse: return "Respuesta inválida del servidor"
        case .serverError(let code): return "Error del servidor (código: \(code))"
        case .deleteFailed: return "No se pudo eliminar el diagnóstico"
        }
    }
}
