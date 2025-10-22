//
//  ReportDataService.swift
//  brew
//
//  Created by toño on 22/10/25.
//

import Foundation
import SwiftData

// MARK: - Report Data Service
/// Manages local storage of reports using SwiftData
@MainActor
class ReportDataService: ObservableObject {
    static let shared = ReportDataService()
    
    @Published var reports: [ReportEntity] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var modelContext: ModelContext?
    
    private init() {
        setupModelContext()
        loadReports()
    }
    
    private func setupModelContext() {
        do {
            let container = try ModelContainer(
                for: ReportEntity.self,
                DiagnosisEntity.self
            )
            modelContext = ModelContext(container)
        } catch {
            print("Failed to create ModelContainer for Reports: \(error)")
            self.error = error
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Save report from API response
    func saveReport(from apiResponse: ReportAPIResponse) throws {
        guard let context = modelContext else {
            throw ReportDataError.contextNotAvailable
        }
        
        let entity = ReportEntity(
            id: apiResponse.reportId,
            title: apiResponse.title,
            userId: apiResponse.userId,
            parcelId: apiResponse.parcelId,
            reportType: apiResponse.reportType,
            reportDate: apiResponse.reportDate,
            notes: apiResponse.notes,
            performanceScore: apiResponse.performanceScore,
            diagnosisCount: apiResponse.diagnosisCount,
            createdAt: apiResponse.createdAt
        )
        
        context.insert(entity)
        
        do {
            try context.save()
            loadReports()
        } catch {
            throw ReportDataError.saveFailed(error)
        }
    }
    
    /// Save multiple reports from API
    func saveReports(_ apiReports: [ReportAPIResponse]) throws {
        guard let context = modelContext else {
            throw ReportDataError.contextNotAvailable
        }
        
        for apiReport in apiReports {
            // Check if report already exists
            let existingReport = getReport(by: apiReport.reportId)
            
            if existingReport == nil {
                let entity = ReportEntity(
                    id: apiReport.reportId,
                    title: apiReport.title,
                    userId: apiReport.userId,
                    parcelId: apiReport.parcelId,
                    reportType: apiReport.reportType,
                    reportDate: apiReport.reportDate,
                    notes: apiReport.notes,
                    performanceScore: apiReport.performanceScore,
                    diagnosisCount: apiReport.diagnosisCount,
                    createdAt: apiReport.createdAt
                )
                context.insert(entity)
            } else {
                // Update existing
                updateReport(existingReport!, from: apiReport)
            }
        }
        
        do {
            try context.save()
            loadReports()
        } catch {
            throw ReportDataError.saveFailed(error)
        }
    }
    
    /// Update existing report entity
    private func updateReport(_ entity: ReportEntity, from apiResponse: ReportAPIResponse) {
        entity.title = apiResponse.title
        entity.parcelId = apiResponse.parcelId
        entity.reportType = apiResponse.reportType
        entity.reportDate = apiResponse.reportDate
        entity.notes = apiResponse.notes
        entity.performanceScore = apiResponse.performanceScore
        entity.diagnosisCount = apiResponse.diagnosisCount
    }
    
    /// Load all reports from local database
    func loadReports() {
        guard let context = modelContext else { return }
        
        isLoading = true
        
        do {
            let descriptor = FetchDescriptor<ReportEntity>(
                sortBy: [SortDescriptor(\.reportDate, order: .reverse)]
            )
            reports = try context.fetch(descriptor)
        } catch {
            self.error = error
            print("Failed to load reports: \(error)")
        }
        
        isLoading = false
    }
    
    /// Load reports for specific user
    func loadReports(forUserId userId: UUID) -> [ReportEntity] {
        guard let context = modelContext else { return [] }
        
        do {
            let descriptor = FetchDescriptor<ReportEntity>(
                predicate: #Predicate { $0.userId == userId },
                sortBy: [SortDescriptor(\.reportDate, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("Failed to load reports for user: \(error)")
            return []
        }
    }
    
    /// Get single report by ID
    func getReport(by id: Int) -> ReportEntity? {
        return reports.first { $0.id == id }
    }
    
    /// Delete report locally
    func deleteReport(_ report: ReportEntity) throws {
        guard let context = modelContext else {
            throw ReportDataError.contextNotAvailable
        }
        
        context.delete(report)
        
        do {
            try context.save()
            loadReports()
        } catch {
            throw ReportDataError.deleteFailed(error)
        }
    }
    
    // MARK: - Statistics
    
    var totalReports: Int {
        reports.count
    }
    
    func reportsByType() -> [String: Int] {
        var byType: [String: Int] = [:]
        for report in reports {
            byType[report.reportType, default: 0] += 1
        }
        return byType
    }
    
    func recentReports(limit: Int = 5) -> [ReportEntity] {
        Array(reports.prefix(limit))
    }
    
    func averagePerformanceScore() -> Double? {
        let scoresReports = reports.compactMap { $0.performanceScore }
        guard !scoresReports.isEmpty else { return nil }
        return scoresReports.reduce(0, +) / Double(scoresReports.count)
    }
}

// MARK: - Errors

enum ReportDataError: LocalizedError {
    case contextNotAvailable
    case saveFailed(Error)
    case deleteFailed(Error)
    case loadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return "Base de datos no disponible"
        case .saveFailed(let error):
            return "Error al guardar reporte: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Error al eliminar reporte: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Error al cargar reportes: \(error.localizedDescription)"
        }
    }
}
