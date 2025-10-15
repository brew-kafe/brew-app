//
//  DiagnosisGenerationView.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import SwiftUI
@preconcurrency import FoundationModels

@available(iOS 18.1, macOS 15.1, *)
struct DiagnosisGenerationView: View {
    let photoAnalysis: [ClassificationResult]
    let capturedImage: UIImage
    let parcelName: String
    let technicianName: String
    let additionalNotes: String
    
    @StateObject private var diagnosisService = FoundationModelsDiagnosisService.shared
    @State private var generatedDiagnosis: AIGeneratedDiagnosis?
    @State private var showingDetailedView = false
    @State private var isNavigatingToDetail = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if !diagnosisService.isModelAvailable {
                        unavailableModelView
                    } else if diagnosisService.isGenerating {
                        generatingView
                    } else if let diagnosis = generatedDiagnosis {
                        completedView(diagnosis: diagnosis)
                    } else {
                        readyToGenerateView
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            diagnosisService.prewarmModel()
        }
        .fullScreenCover(isPresented: $showingDetailedView) {
            if let diagnosis = generatedDiagnosis {
                DetailedDiagnosisView(
                    diagnosis: diagnosis,
                    capturedImage: capturedImage,
                    parcelName: parcelName,
                    technicianName: technicianName
                )
            }
        }
    }
    
    // MARK: - Model Unavailable View
    
    private var unavailableModelView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Foundation Models Unavailable")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(diagnosisService.availabilityMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Go Back") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Ready to Generate View
    
    private var readyToGenerateView: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("AI Diagnosis Generation")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Generate comprehensive plant diagnosis using Apple Intelligence")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            // Photo Preview
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
            
            // Analysis Summary
            VStack(alignment: .leading, spacing: 10) {
                Text("Photo Analysis Results")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(photoAnalysis.prefix(3), id: \.identifier) { result in
                            HStack {
                                Circle()
                                    .fill(confidenceColor(for: Double(result.confidence)))
                                    .frame(width: 8, height: 8)
                                
                                Text(result.displayName)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(Int(result.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(maxHeight: 80)
            }
            
            Spacer()
            
            // Generate Button
            Button(action: generateDiagnosis) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Diagnosis")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: diagnosisService.isGenerating)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Generating View
    
    private var generatingView: some View {
        VStack(spacing: 30) {
            // Animated sparkles
            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.7))
                        .rotationEffect(.degrees(Double(index) * 45))
                        .offset(y: -40)
                        .scaleEffect(diagnosisService.isGenerating ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: diagnosisService.isGenerating
                        )
                }
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 10) {
                Text("Generating Diagnosis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(diagnosisService.generationProgress)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut, value: diagnosisService.generationProgress)
            }
            
            // Progress indicator
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            // Streaming content preview
            if let partialDiagnosis = diagnosisService.currentDiagnosis {
                streamingContentPreview(partialDiagnosis)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Completed View
    
    private func completedView(diagnosis: AIGeneratedDiagnosis) -> some View {
        VStack(spacing: 20) {
            // Success indicator
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .scaleEffect(isNavigatingToDetail ? 1.1 : 1.0)
                .animation(.spring(), value: isNavigatingToDetail)
            
            Text("Diagnosis Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            // Quick summary
            VStack(alignment: .leading, spacing: 10) {
                Text(diagnosis.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Label("Confidence", systemImage: "chart.bar.fill")
                    Spacer()
                    Text("\(Int(diagnosis.confidencePercentage))%")
                        .fontWeight(.semibold)
                        .foregroundColor(confidenceColor(for: diagnosis.confidencePercentage / 100))
                }
                
                HStack {
                    Label("Primary Issue", systemImage: "leaf.fill")
                    Spacer()
                    Text(diagnosis.primaryDeficiency)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Label("Element", systemImage: "atom")
                    Spacer()
                    Text(diagnosis.deficiencyElement)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    isNavigatingToDetail = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingDetailedView = true
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("View Detailed Diagnosis")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button("Generate New Diagnosis") {
                    generatedDiagnosis = nil
                    diagnosisService.resetGeneration()
                }
                .foregroundColor(.blue)
                
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Streaming Content Preview
    
    private func streamingContentPreview(_ partial: AIGeneratedDiagnosis.PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analysis Preview")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title = partial.title {
                    Text(title)
                        .font(.headline)
                        .transition(.opacity)
                }
                
                if let deficiency = partial.primaryDeficiency {
                    Text("Primary Issue: \(deficiency)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .animation(.easeInOut, value: partial.title)
        .animation(.easeInOut, value: partial.primaryDeficiency)
    }
    
    // MARK: - Helper Methods
    
    private func generateDiagnosis() {
        Task {
            do {
                let diagnosis = try await diagnosisService.generateDiagnosis(
                    from: photoAnalysis,
                    parcelInfo: "Parcel: \(parcelName), Technician: \(technicianName)",
                    additionalNotes: additionalNotes
                )
                
                await MainActor.run {
                    self.generatedDiagnosis = diagnosis
                }
            } catch {
                print("Diagnosis generation failed: \(error)")
            }
        }
    }
    
    private func confidenceColor(for confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.6 { return .orange }
        else { return .red }
    }
}

#Preview {
    DiagnosisGenerationView(
        photoAnalysis: [
            ClassificationResult(identifier: "deficiency_1", confidence: 0.85, nutrient: "Nitrogen", severity: "Moderate", displayName: "Nitrogen Deficiency"),
            ClassificationResult(identifier: "deficiency_2", confidence: 0.72, nutrient: "Phosphorus", severity: "Mild", displayName: "Phosphorus Deficiency")
        ],
        capturedImage: UIImage(systemName: "leaf.fill")!,
        parcelName: "Parcela 1",
        technicianName: "John Doe",
        additionalNotes: "Leaves showing yellowing patterns"
    )
}
