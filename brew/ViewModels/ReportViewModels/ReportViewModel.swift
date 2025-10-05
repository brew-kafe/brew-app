//
//  ReportViewModel.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI

@MainActor
class ReportViewModel: ObservableObject {
    @Published var reports: [DetailedReportData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        loadMockData()
    }
    
    func loadMockData() {
        // Load sample reports with different statuses
        reports = [
            DetailedReportData.sample,
            DetailedReportData.sampleHealthy
        ]
    }
    
    func refreshReports() {
        isLoading = true
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadMockData()
            self.isLoading = false
        }
    }
    
    func addReport(_ report: DetailedReportData) {
        reports.append(report)
    }
    
    func deleteReport(_ report: DetailedReportData) {
        reports.removeAll { $0.id == report.id }
    }
}
