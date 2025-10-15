//
//  AIDiagnosisListView.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import SwiftUI

struct AIDiagnosisListView: View {
    @StateObject private var dataService = AIDiagnosisDataService.shared
    @State private var selectedDiagnosis: AIDiagnosisEntity?
    @State private var showingDetail = false
    @State private var searchText = ""
    @State private var selectedFilter: DiagnosisFilter = .all
    
    enum DiagnosisFilter: String, CaseIterable {
        case all = "All"
        case danger = "Critical"
        case moderate = "Moderate" 
        case optimal = "Optimal"
        
        var systemImage: String {
            switch self {
            case .all: return "list.bullet"
            case .danger: return "exclamationmark.triangle.fill"
            case .moderate: return "exclamationmark.circle.fill"
            case .optimal: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .danger: return .red
            case .moderate: return .orange
            case .optimal: return .green
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics Header
                if !dataService.diagnoses.isEmpty {
                    statisticsHeader
                        .padding()
                        .background(Color(.systemGray6))
                }
                
                // Filter Selector
                filterSelector
                
                // Diagnosis List
                if dataService.isLoading {
                    ProgressView("Loading diagnoses...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredDiagnoses.isEmpty {
                    emptyStateView
                } else {
                    diagnosisList
                }
            }
            .navigationTitle("AI Diagnoses")
            .searchable(text: $searchText, prompt: "Search by parcel, technician, or deficiency")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Refresh") {
                            dataService.loadDiagnoses()
                        }
                        
                        Button("Export Data") {
                            // TODO: Implement export functionality
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(item: $selectedDiagnosis) { diagnosis in
            AIDiagnosisDetailView(diagnosis: diagnosis)
        }
        .onAppear {
            dataService.loadDiagnoses()
        }
    }
    
    // MARK: - Statistics Header
    
    private var statisticsHeader: some View {
        HStack(spacing: 20) {
            StatisticCard(
                title: "Total",
                value: "\(dataService.totalDiagnoses)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            StatisticCard(
                title: "Avg Confidence",
                value: "\(Int(dataService.averageConfidence))%",
                icon: "chart.bar.fill",
                color: .green
            )
            
            if let common = dataService.mostCommonDeficiency {
                StatisticCard(
                    title: "Most Common",
                    value: common.prefix(8) + "...",
                    icon: "leaf.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Filter Selector
    
    private var filterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DiagnosisFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: filter.systemImage)
                                .font(.caption)
                            Text(filter.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedFilter == filter ? filter.color : Color(.systemGray5)
                        )
                        .foregroundColor(
                            selectedFilter == filter ? .white : .primary
                        )
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Diagnosis List
    
    private var diagnosisList: some View {
        List {
            ForEach(filteredDiagnoses, id: \.id) { diagnosis in
                AIDiagnosisRowView(diagnosis: diagnosis) {
                    selectedDiagnosis = diagnosis
                }
                .swipeActions(edge: .trailing) {
                    Button("Delete", role: .destructive) {
                        deleteDiagnosis(diagnosis)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No AI Diagnoses Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start by taking a photo and generating an AI diagnosis")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Get Started") {
                // Navigate to camera or diagnosis flow
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var filteredDiagnoses: [AIDiagnosisEntity] {
        var diagnoses = dataService.diagnoses
        
        // Apply search filter
        if !searchText.isEmpty {
            diagnoses = diagnoses.filter { diagnosis in
                diagnosis.parcelName.localizedCaseInsensitiveContains(searchText) ||
                diagnosis.technicianName.localizedCaseInsensitiveContains(searchText) ||
                diagnosis.primaryDeficiency.localizedCaseInsensitiveContains(searchText) ||
                diagnosis.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply detection state filter
        switch selectedFilter {
        case .all:
            break
        case .danger:
            diagnoses = diagnoses.filter { $0.detectionState == "danger" }
        case .moderate:
            diagnoses = diagnoses.filter { $0.detectionState == "moderate" }
        case .optimal:
            diagnoses = diagnoses.filter { $0.detectionState == "optimal" }
        }
        
        return diagnoses
    }
    
    // MARK: - Actions
    
    private func deleteDiagnosis(_ diagnosis: AIDiagnosisEntity) {
        do {
            try dataService.deleteDiagnosis(diagnosis)
        } catch {
            print("Failed to delete diagnosis: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct AIDiagnosisRowView: View {
    let diagnosis: AIDiagnosisEntity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(diagnosis.title)
                            .font(.headline)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(diagnosis.parcelName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(diagnosis.confidencePercentage))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(confidenceColor.opacity(0.2))
                            .foregroundColor(confidenceColor)
                            .cornerRadius(4)
                        
                        Text(stateDisplayName)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(stateColor.opacity(0.2))
                            .foregroundColor(stateColor)
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    Label("Primary Issue", systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(diagnosis.primaryDeficiency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(diagnosis.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var confidenceColor: Color {
        let confidence = diagnosis.confidencePercentage / 100
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.6 { return .orange }
        else { return .red }
    }
    
    private var stateColor: Color {
        switch diagnosis.detectionState {
        case "danger": return .red
        case "moderate": return .orange
        case "optimal": return .green
        default: return .gray
        }
    }
    
    private var stateDisplayName: String {
        switch diagnosis.detectionState {
        case "danger": return "Critical"
        case "moderate": return "Moderate"
        case "optimal": return "Optimal"
        default: return "Unknown"
        }
    }
}

#Preview {
    AIDiagnosisListView()
}