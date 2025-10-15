//
//  DetailedDiagnosisView.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import SwiftUI

@available(iOS 18.1, macOS 15.1, *)
struct DetailedDiagnosisView: View {
    let diagnosis: AIGeneratedDiagnosis
    let capturedImage: UIImage
    let parcelName: String
    let technicianName: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingSaveConfirmation = false
    @State private var isSaving = false
    @StateObject private var dataService = AIDiagnosisDataService.shared
    
    init(diagnosis: AIGeneratedDiagnosis, capturedImage: UIImage, parcelName: String, technicianName: String) {
        self.diagnosis = diagnosis
        self.capturedImage = capturedImage
        self.parcelName = parcelName
        self.technicianName = technicianName
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with diagnosis title and confidence
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
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveDiagnosis) {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .alert("Diagnosis Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("The diagnosis has been saved to your database.")
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // Confidence indicator
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
        ("Action Plan", "list.bullet")
    ]
    
    // MARK: - Tab Views
    
    private var overviewTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Plant photo
                VStack(alignment: .leading, spacing: 10) {
                    Text("Analyzed Photo")
                        .font(.headline)
                    
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                }
                
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
            }
            .padding()
        }
    }
    
    private var elementAnalysisTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(diagnosis.elementAnalysis, id: \.element) { element in
                    ElementAnalysisCard(element: element)
                }
            }
            .padding()
        }
    }
    
    private var recommendationsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // General recommendations
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
                
                // Long-term care
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
            .padding()
        }
    }
    
    private var actionPlanTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Immediate actions
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
                
                // Summary card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Diagnosis Summary")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        summaryRow("Parcel", parcelName)
                        summaryRow("Technician", technicianName)
                        summaryRow("Date", DateFormatter.shortDateFormatter.string(from: Date()))
                        summaryRow("Primary Issue", diagnosis.primaryDeficiency)
                        summaryRow("Affected Element", diagnosis.deficiencyElement)
                        summaryRow("Severity", diagnosis.detectionState.capitalized)
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
    
    // MARK: - Actions
    
    private func saveDiagnosis() {
        isSaving = true
        
        Task {
            do {
                try await dataService.saveDiagnosis(
                    diagnosis,
                    parcelName: parcelName,
                    technicianName: technicianName,
                    additionalNotes: nil, // You can add this parameter if needed
                    photoUrls: [] // You'll need to handle photo storage separately
                )
                
                await MainActor.run {
                    isSaving = false
                    showingSaveConfirmation = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    // Handle error - you might want to show an error alert
                    print("Failed to save diagnosis: \(error)")
                }
            }
        }
    }
}

// MARK: - Element Analysis Card

struct ElementAnalysisCard: View {
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
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    DetailedDiagnosisView(
        diagnosis: AIGeneratedDiagnosis(
            title: "Nitrogen Deficiency with Secondary Phosphorus Issues",
            detailedDescription: "The coffee plant shows classic signs of nitrogen deficiency with yellowing leaves and stunted growth. Secondary phosphorus deficiency is also evident in the purple leaf edges.",
            primaryDeficiency: "Nitrogen Deficiency",
            deficiencyElement: "Nitrogen (N)",
            detectionState: "moderate",
            confidencePercentage: 85.0,
            recommendations: [
                "Apply nitrogen-rich fertilizer immediately",
                "Increase watering frequency",
                "Monitor plant progress weekly"
            ],
            elementAnalysis: [
                ElementAnalysisAI(
                    element: "Nitrogen",
                    percentage: 35.0,
                    detectionState: "danger",
                    deficiencyLevel: "Severe",
                    recommendations: ["Apply urea fertilizer", "Increase organic matter"]
                )
            ],
            immediateActions: [
                "Apply nitrogen fertilizer within 24 hours",
                "Increase irrigation"
            ],
            longTermCare: [
                "Establish regular fertilization schedule",
                "Monitor soil pH levels"
            ],
            expectedRecoveryTime: "2-3 weeks with proper treatment",
            riskAssessment: "Moderate risk if left untreated"
        ),
        capturedImage: UIImage(systemName: "leaf.fill")!,
        parcelName: "Parcela 1",
        technicianName: "John Doe"
    )
}