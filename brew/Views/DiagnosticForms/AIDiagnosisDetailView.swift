//
//  AIDiagnosisDetailView.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import SwiftUI

struct AIDiagnosisDetailView: View {
    let diagnosis: AIDiagnosisEntity
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    init(diagnosis: AIDiagnosisEntity) {
        self.diagnosis = diagnosis
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with diagnosis info
                headerView
                
                // Tab selection
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    overviewTab.tag(0)
                    elementAnalysisTab.tag(1)
                    recommendationsTab.tag(2)
                    actionPlanTab.tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Saved Diagnosis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Share Report") {
                            // TODO: Implement sharing
                        }
                        
                        Button("Export PDF") {
                            // TODO: Implement PDF export
                        }
                        
                        Button("Edit Notes") {
                            // TODO: Implement editing
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // Confidence and state indicators
            HStack {
                Circle()
                    .fill(confidenceColor)
                    .frame(width: 12, height: 12)
                
                Text("AI Confidence: \(Int(diagnosis.confidencePercentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(diagnosis.detectionState.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(stateColor.opacity(0.2))
                    .foregroundColor(stateColor)
                    .cornerRadius(6)
            }
            
            // Title
            Text(diagnosis.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Primary deficiency
            Text("\(diagnosis.primaryDeficiency) - \(diagnosis.deficiencyElement)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Metadata
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Parcel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(diagnosis.parcelName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(diagnosis.createdAt, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Technician")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(diagnosis.technicianName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabItems.enumerated()), id: \.offset) { index, item in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16))
                        Text(item.title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.blue)
                .offset(x: CGFloat(selectedTab) * (UIScreen.main.bounds.width / 4) - UIScreen.main.bounds.width * 3/8)
                .animation(.spring(), value: selectedTab),
            alignment: .bottom
        )
    }
    
    private var tabItems: [(title: String, icon: String)] = [
        ("Overview", "doc.text"),
        ("Elements", "atom"),
        ("Treatment", "leaf.fill"),
        ("Actions", "list.bullet")
    ]
    
    // MARK: - Tab Views
    
    private var overviewTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Detailed description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Diagnosis Details")
                        .font(.headline)
                    
                    Text(diagnosis.detailedDescription)
                        .font(.body)
                        .lineSpacing(2)
                }
                
                // Risk assessment
                VStack(alignment: .leading, spacing: 10) {
                    Label("Risk Assessment", systemImage: "exclamationmark.triangle")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text(diagnosis.riskAssessment)
                        .font(.body)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Recovery time
                VStack(alignment: .leading, spacing: 10) {
                    Label("Expected Recovery", systemImage: "clock")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text(diagnosis.expectedRecoveryTime)
                        .font(.body)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Additional notes if available
                if let notes = diagnosis.additionalNotes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Additional Notes", systemImage: "note.text")
                            .font(.headline)
                        
                        Text(notes)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
    
    private var elementAnalysisTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                if diagnosis.elementAnalysis.isEmpty {
                    Text("No element analysis data available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(diagnosis.elementAnalysis, id: \.element) { element in
                        SavedElementAnalysisCard(element: element)
                    }
                }
            }
            .padding()
        }
    }
    
    private var recommendationsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // General recommendations
                if !diagnosis.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Treatment Recommendations")
                            .font(.headline)
                        
                        ForEach(Array(diagnosis.recommendations.enumerated()), id: \.offset) { index, recommendation in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(width: 20, height: 20)
                                    .background(Circle().fill(Color.blue))
                                    .foregroundColor(.white)
                                
                                Text(recommendation)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Divider()
                }
                
                // Long-term care
                if !diagnosis.longTermCare.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Long-term Care Plan")
                            .font(.headline)
                        
                        ForEach(Array(diagnosis.longTermCare.enumerated()), id: \.offset) { index, care in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                
                                Text(care)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if diagnosis.recommendations.isEmpty && diagnosis.longTermCare.isEmpty {
                    Text("No treatment recommendations available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
    }
    
    private var actionPlanTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Immediate actions
                if !diagnosis.immediateActions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Immediate Actions Required", systemImage: "exclamationmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        ForEach(Array(diagnosis.immediateActions.enumerated()), id: \.offset) { index, action in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Priority \(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    
                                    Text(action)
                                        .font(.body)
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("No Immediate Actions Required", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("The plant condition is stable and doesn't require immediate intervention.")
                            .font(.body)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Summary card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Diagnosis Summary")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        summaryRow("Diagnosis ID", diagnosis.id.uuidString.prefix(8) + "...")
                        summaryRow("Created", DateFormatter.detailedDateFormatter.string(from: diagnosis.createdAt))
                        summaryRow("Diagnosis Date", DateFormatter.detailedDateFormatter.string(from: diagnosis.diagnosisDate))
                        summaryRow("Primary Issue", diagnosis.primaryDeficiency)
                        summaryRow("Affected Element", diagnosis.deficiencyElement)
                        summaryRow("Severity", diagnosis.detectionState.capitalized)
                        summaryRow("AI Confidence", "\(Int(diagnosis.confidencePercentage))%")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Views
    
    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Helper Properties
    
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
}

// MARK: - Supporting Views

struct SavedElementAnalysisCard: View {
    let element: ElementAnalysisAI
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(element.element)
                        .font(.headline)
                    
                    Text(element.deficiencyLevel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(element.percentage))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(stateColor)
                    
                    Text(element.detectionState.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(stateColor.opacity(0.2))
                        .foregroundColor(stateColor)
                        .cornerRadius(4)
                }
            }
            
            // Progress bar
            ProgressView(value: element.percentage / 100)
                .tint(stateColor)
            
            // Recommendations for this element
            if !element.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommendations:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(element.recommendations, id: \.self) { recommendation in
                        Text("• \(recommendation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var stateColor: Color {
        switch element.detectionState {
        case "danger": return .red
        case "moderate": return .orange
        case "optimal": return .green
        default: return .gray
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let detailedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    AIDiagnosisDetailView(
        diagnosis: AIDiagnosisEntity(
            title: "Sample Diagnosis",
            detailedDescription: "This is a sample diagnosis description",
            primaryDeficiency: "Nitrogen Deficiency",
            deficiencyElement: "Nitrogen",
            detectionState: "moderate",
            confidencePercentage: 85.0,
            parcelName: "Sample Parcel",
            technicianName: "John Doe",
            expectedRecoveryTime: "2-3 weeks",
            riskAssessment: "Moderate risk"
        )
    )
}