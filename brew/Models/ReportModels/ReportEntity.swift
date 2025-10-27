//
//  ReportEntity.swift
//  brew
//
//  Created by toño on 22/10/25.
//

import Foundation
import SwiftData

/// SwiftData model for storing reports locally
@Model
class ReportEntity {
    @Attribute(.unique) var id: Int // Using Int to match API report_id, or negative for local-only
    var title: String
    var userId: UUID
    var parcelId: Int?
    var reportType: String
    var reportDate: Date
    var notes: String?
    var performanceScore: Double?
    var diagnosisCount: Int
    var createdAt: Date
    var needsSync: Bool = false // Indicates if this report needs to be synced to API
    
    // Store diagnosis IDs as JSON
    var diagnosisIdsData: Data?
    
    // Relationships (if you want to link to local DiagnosisEntity)
    // Note: This requires careful sync logic
    @Relationship(deleteRule: .nullify) var linkedDiagnoses: [DiagnosisEntity]?
    
    init(
        id: Int,
        title: String,
        userId: UUID,
        parcelId: Int? = nil,
        reportType: String = "nutrition",
        reportDate: Date = Date(),
        notes: String? = nil,
        performanceScore: Double? = nil,
        diagnosisCount: Int = 0,
        diagnosisIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.userId = userId
        self.parcelId = parcelId
        self.reportType = reportType
        self.reportDate = reportDate
        self.notes = notes
        self.performanceScore = performanceScore
        self.diagnosisCount = diagnosisCount
        self.createdAt = createdAt
        
        // Encode diagnosis IDs to JSON
        if !diagnosisIds.isEmpty {
            self.diagnosisIdsData = try? JSONEncoder().encode(diagnosisIds)
        }
    }
    
    /// Convenience initializer for local-only reports (when API is unavailable)
    convenience init(
        title: String,
        reportType: String = "nutrition",
        notes: String? = nil,
        performanceScore: Double? = nil,
        reportDate: Date = Date(),
        createdAt: Date = Date(),
        userId: UUID,
        parcelId: Int? = nil,
        needsSync: Bool = false
    ) {
        // Use negative ID for local-only reports to avoid conflicts with API IDs
        let localId = -Int(Date().timeIntervalSince1970)
        
        self.init(
            id: localId,
            title: title,
            userId: userId,
            parcelId: parcelId,
            reportType: reportType,
            reportDate: reportDate,
            notes: notes,
            performanceScore: performanceScore,
            diagnosisCount: 0,
            diagnosisIds: [],
            createdAt: createdAt
        )
        
        self.needsSync = needsSync
    }
    
    // MARK: - Computed Properties
    
    var diagnosisIds: [UUID] {
        guard let data = diagnosisIdsData,
              let decoded = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return decoded
    }
    
    var reportTypeEnum: ReportType? {
        ReportType(rawValue: reportType)
    }
}

// MARK: - Extensions

extension ReportEntity {
    /// Convert to API response model
    func toAPIResponse() -> ReportAPIResponse {
        return ReportAPIResponse(
            reportId: id,
            title: title,
            userId: userId,
            parcelId: parcelId,
            reportType: reportType,
            reportDate: reportDate,
            notes: notes,
            performanceScore: performanceScore,
            diagnosisCount: diagnosisCount,
            createdAt: createdAt
        )
    }
}
