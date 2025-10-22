//
//  DiagnosisGenerationView.swift
//  brew
//
//  Created by Claude on 20/10/25.
//

import SwiftUI
import UIKit

@available(iOS 18.1, macOS 15.1, *)
struct DiagnosisGenerationView: View {
    let photoAnalysis: [ClassificationResult]
    let capturedImage: UIImage
    let parcelName: String
    let technicianName: String
    let additionalNotes: String
    let diagnosisViewModel: DiagnosisViewModel

    @StateObject private var foundationService = FoundationModelsDiagnosisService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var generatedDiagnosis: AIGeneratedDiagnosis?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isComplete = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 88/255, green: 92/255, blue: 48/255).opacity(0.1),
                        Color(red: 88/255, green: 92/255, blue: 48/255).opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Image Preview
                        imagePreviewSection

                        // CoreML Analysis Results
                        analysisResultsSection

                        // Generation Progress or Results
                        if isComplete, let diagnosis = generatedDiagnosis {
                            diagnosisResultsSection(diagnosis: diagnosis)
                        } else if foundationService.isGenerating {
                            generationProgressSection
                        }

                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Diagnosis Generation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !foundationService.isGenerating {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .task {
                // Auto-start generation when view appears
                await generateDiagnosis()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: foundationService.isGenerating ? "brain.head.profile" : (isComplete ? "checkmark.circle.fill" : "sparkles"))
                .font(.system(size: 50))
                .foregroundColor(isComplete ? .green : .brown)
                .symbolEffect(.bounce, value: foundationService.isGenerating)

            Text(isComplete ? "Diagnosis Complete" : (foundationService.isGenerating ? "Generating AI Diagnosis" : "AI Diagnosis"))
                .font(.title2)
                .fontWeight(.bold)

            if !foundationService.isGenerating && !isComplete {
                Text("Using Apple Foundation Models")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Image Preview Section

    private var imagePreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Captured Plant Image")
                .font(.headline)
                .padding(.horizontal)

            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal)
        }
    }

    // MARK: - Analysis Results Section

    private var analysisResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.blue)
                Text("CoreML Analysis Results")
                    .font(.headline)
            }
            .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(photoAnalysis.prefix(3), id: \.identifier) { result in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            if let nutrient = result.nutrient {
                                Text("Affects: \(nutrient)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(Int(result.confidence * 100))%")
                                .font(.headline)
                                .foregroundColor(.blue)

                            Text(result.severity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(severityColor(result.severity).opacity(0.2))
                                )
                                .foregroundColor(severityColor(result.severity))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Generation Progress Section

    private var generationProgressSection: some View {
        VStack(spacing: 16) {
            // Progress indicator
            ProgressView()
                .scaleEffect(1.5)
                .tint(.brown)

            // Status message
            Text(foundationService.generationProgress)
                .font(.headline)
                .multilineTextAlignment(.center)

            // Partial results preview (if available)
            if let partial = foundationService.currentDiagnosis {
                VStack(alignment: .leading, spacing: 12) {
                    if let title = partial.title {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.green)
                            Text(title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }

                    if let primaryDeficiency = partial.primaryDeficiency {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Primary Issue: \(primaryDeficiency)")
                                .font(.caption)
                        }
                    }

                    if let confidence = partial.confidencePercentage {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Confidence: \(Int(confidence))%")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
                .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Diagnosis Results Section

    private func diagnosisResultsSection(diagnosis: AIGeneratedDiagnosis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text(diagnosis.title)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Divider()

            // Primary Info
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "exclamationmark.triangle.fill", label: "Primary Deficiency", value: diagnosis.primaryDeficiency, color: .orange)
                infoRow(icon: "atom", label: "Element", value: diagnosis.deficiencyElement, color: .purple)
                infoRow(icon: "heart.fill", label: "Detection State", value: diagnosis.detectionState.capitalized, color: detectionStateColor(diagnosis.detectionState))
                infoRow(icon: "chart.line.uptrend.xyaxis", label: "AI Confidence", value: "\(Int(diagnosis.confidencePercentage))%", color: .blue)
            }

            Divider()

            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Detailed Analysis")
                    .font(.headline)

                Text(diagnosis.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Immediate Actions
            VStack(alignment: .leading, spacing: 8) {
                Text("Immediate Actions")
                    .font(.headline)

                ForEach(diagnosis.immediateActions, id: \.self) { action in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(action)
                            .font(.subheadline)
                    }
                }
            }

            Divider()

            // Recommendations
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommendations")
                    .font(.headline)

                ForEach(diagnosis.recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(recommendation)
                            .font(.subheadline)
                    }
                }
            }

            Divider()

            // Recovery Info
            VStack(alignment: .leading, spacing: 8) {
                infoRow(icon: "clock.fill", label: "Expected Recovery", value: diagnosis.expectedRecoveryTime, color: .cyan)

                Text("Risk Assessment")
                    .font(.headline)
                    .padding(.top, 4)

                Text(diagnosis.riskAssessment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if isComplete {
                Button(action: saveDiagnosis) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Save Diagnosis")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Button(action: { dismiss() }) {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            } else if !foundationService.isGenerating && generatedDiagnosis == nil {
                Button(action: { Task { await generateDiagnosis() } }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry Generation")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Helper Views

    private func infoRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()
        }
    }

    // MARK: - Helper Functions

    private func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "severe": return .red
        case "moderate": return .orange
        case "mild": return .yellow
        default: return .gray
        }
    }

    private func detectionStateColor(_ state: String) -> Color {
        switch state.lowercased() {
        case "danger": return .red
        case "moderate": return .orange
        case "optimal": return .green
        default: return .gray
        }
    }

    // MARK: - Actions

    private func generateDiagnosis() async {
        guard !foundationService.isGenerating else { return }

        do {
            let parcelInfo = """
            Parcel: \(parcelName)
            Technician: \(technicianName)
            Additional Notes: \(additionalNotes.isEmpty ? "None" : additionalNotes)
            """

            let diagnosis = try await foundationService.generateDiagnosis(
                from: photoAnalysis,
                parcelInfo: parcelInfo,
                additionalNotes: additionalNotes
            )

            await MainActor.run {
                generatedDiagnosis = diagnosis
                isComplete = true
            }

        } catch {
            await MainActor.run {
                errorMessage = "Failed to generate diagnosis: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    private func saveDiagnosis() {
        guard let diagnosis = generatedDiagnosis else { return }

        // Convert AIGeneratedDiagnosis to DiagnosisEntity
        let entity = DiagnosisEntity(
            parcelName: parcelName,
            plantNumber: nil, // Could be added to the form if needed
            technicianName: technicianName,
            primaryDeficiency: diagnosis.primaryDeficiency,
            deficiencyElement: diagnosis.deficiencyElement,
            detectionState: diagnosis.detectionState,
            aiConfidence: diagnosis.confidencePercentage / 100.0,
            aiDescription: diagnosis.detailedDescription,
            aiRecommendations: diagnosis.recommendations,
            allElements: diagnosis.elementAnalysis.map { aiElement in
                ElementAnalysis(
                    element: aiElement.element,
                    percentage: aiElement.percentage,
                    detectionState: aiElement.detectionState,
                    deficiencyLevel: aiElement.deficiencyLevel,
                    recommendations: aiElement.recommendations
                )
            },
            photoURLs: [], // Could save the captured image if needed
            diagnosisDate: Date(),
            createdAt: Date()
        )

        // Add to diagnosis list
        diagnosisViewModel.diagnosesList.insert(entity, at: 0)

        // Optionally, persist using AIDiagnosisDataService as well
        if #available(iOS 18.1, *) {
            do {
                try AIDiagnosisDataService.shared.saveDiagnosis(
                    diagnosis,
                    parcelName: parcelName,
                    technicianName: technicianName,
                    additionalNotes: additionalNotes.isEmpty ? nil : additionalNotes,
                    photoUrls: []
                )
            } catch {
                print("Failed to save to AIDiagnosisDataService: \(error)")
            }
        }

        dismiss()
    }
}

// MARK: - Preview

@available(iOS 18.1, macOS 15.1, *)
#Preview {
    DiagnosisGenerationView(
        photoAnalysis: [
            ClassificationResult(
                identifier: "nitrogeno",
                confidence: 0.85,
                nutrient: "nitrogen",
                severity: "moderate",
                displayName: "Deficiencia de Nitrógeno"
            )
        ],
        capturedImage: UIImage(systemName: "leaf.fill")!,
        parcelName: "Parcela Test",
        technicianName: "Test Technician",
        additionalNotes: "Test notes",
        diagnosisViewModel: DiagnosisViewModel()
    )
}
