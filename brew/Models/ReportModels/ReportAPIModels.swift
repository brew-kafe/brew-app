//
//  ReportAPIModels.swift
//  brew
//
//  Created by toño on 22/10/25.
//

import Foundation

// MARK: - Report API Request Models

/// Request model for creating a new report
struct ReportCreateRequest: Codable {
    let title: String
    let userId: UUID
    let diagnosisIds: [UUID]
    let parcelId: Int?
    let reportType: String
    let notes: String?
    let performanceScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case title
        case userId = "user_id"
        case diagnosisIds = "diagnosis_ids"
        case parcelId = "parcel_id"
        case reportType = "report_type"
        case notes
        case performanceScore = "performance_score"
    }
}

// MARK: - Report API Response Models

/// Basic report response from API
struct ReportAPIResponse: Codable {
    let reportId: Int
    let title: String
    let userId: UUID
    let parcelId: Int?
    let reportType: String
    let reportDate: Date
    let notes: String?
    let performanceScore: Double?
    let diagnosisCount: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case reportId = "report_id"
        case title
        case userId = "user_id"
        case parcelId = "parcel_id"
        case reportType = "report_type"
        case reportDate = "report_date"
        case notes
        case performanceScore = "performance_score"
        case diagnosisCount = "diagnosis_count"
        case createdAt = "created_at"
    }
}

/// Diagnosis summary included in report details
struct DiagnosisSummaryAPI: Codable, Identifiable {
    var id: String { diagnosisId }
    
    let diagnosisId: String
    let parcelName: String
    let plantNumber: String?
    let primaryDeficiency: String
    let deficiencyElement: String
    let detectionState: String
    let aiConfidence: Double?
    let diagnosisDate: String
    
    enum CodingKeys: String, CodingKey {
        case diagnosisId = "diagnosis_id"
        case parcelName = "parcel_name"
        case plantNumber = "plant_number"
        case primaryDeficiency = "primary_deficiency"
        case deficiencyElement = "deficiency_element"
        case detectionState = "detection_state"
        case aiConfidence = "ai_confidence"
        case diagnosisDate = "diagnosis_date"
    }
}

/// Full report with included diagnoses
struct ReportWithDiagnosesAPI: Codable {
    let reportId: Int
    let title: String
    let userId: UUID
    let parcelId: Int?
    let reportType: String
    let reportDate: Date
    let notes: String?
    let performanceScore: Double?
    let diagnosisCount: Int
    let createdAt: Date
    let diagnoses: [DiagnosisSummaryAPI]
    
    enum CodingKeys: String, CodingKey {
        case reportId = "report_id"
        case title
        case userId = "user_id"
        case parcelId = "parcel_id"
        case reportType = "report_type"
        case reportDate = "report_date"
        case notes
        case performanceScore = "performance_score"
        case diagnosisCount = "diagnosis_count"
        case createdAt = "created_at"
        case diagnoses
    }
}

// MARK: - Report Type Enum

enum ReportType: String, Codable, CaseIterable {
    case nutrition = "nutrition"
    case water = "water"
    case disease = "disease"
    case performance = "performance"
    
    var displayName: String {
        switch self {
        case .nutrition: return "Nutrición"
        case .water: return "Riego"
        case .disease: return "Enfermedades"
        case .performance: return "Rendimiento"
        }
    }
    
    var icon: String {
        switch self {
        case .nutrition: return "leaf.fill"
        case .water: return "drop.fill"
        case .disease: return "cross.case.fill"
        case .performance: return "chart.bar.fill"
        }
    }
}

// MARK: - Report Statistics

struct ReportStatsResponse: Codable {
    let totalReports: Int
    let byType: [String: Int]
    let recentReports: [ReportAPIResponse]
    
    enum CodingKeys: String, CodingKey {
        case totalReports = "total_reports"
        case byType = "by_type"
        case recentReports = "recent_reports"
    }
}
