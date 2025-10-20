import SwiftUI

struct DiagnosticView: View {
    @StateObject var viewModel = DiagnosisViewModel()
    @StateObject private var aiDataService = AIDiagnosisDataService.shared
    @State private var showCamera = false
    @State private var showDynamicGeneration = false
    @State private var capturedImageForGeneration: UIImage?
    @State private var selectedDiagnosis: DiagnosisEntity?
    @State private var selectedAIDiagnosis: AIDiagnosisEntity?
    @State private var selectedSegment = 0 // 0 = Regular, 1 = AI Diagnoses

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Esto está abajo del título")
            }
            .navigationTitle("Diagnósticos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Camera Button
                    Button(action: { 
                        showCamera = true
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255)))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Abrir cámara para diagnóstico")
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView()
            }
            .fullScreenCover(isPresented: $showDynamicGeneration) {
                DynamicDiagnosisGenerationView(
                    diagnosisViewModel: viewModel,
                    capturedImage: capturedImageForGeneration
                ) { generatedDiagnosis in
                    showDynamicGeneration = false
                    // Optionally navigate to detail view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        selectedDiagnosis = generatedDiagnosis
                    }
                }
            }
            .sheet(item: $selectedDiagnosis) { diagnosis in
                DiagnosticDetailView(diagnosis: diagnosis, viewModel: viewModel)
            }
        }
        .onAppear {
            aiDataService.loadDiagnoses()
        }
    }
    
    // MARK: - Regular Diagnoses View
    
    private var regularDiagnosesView: some View {
        VStack {
            if viewModel.diagnoses.isEmpty {
                emptyStateView(
                    title: "No se han generado diagnósticos",
                    subtitle: "Empieza con tomar una foto",
                    systemImage: "doc.text"
                )
            } else {
                List(viewModel.diagnoses) { diagnosis in
                    Button {
                        selectedDiagnosis = diagnosis
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(diagnosis.parcelName)
                                    .font(.headline)
                                Spacer()
                                Text(dateFormatter.string(from: diagnosis.diagnosisDate))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Text(diagnosis.plantNumber ?? "N/A")
                                .font(.subheadline)
                            Text("Técnico: \(diagnosis.technicianName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(diagnosis.primaryDeficiency)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - Empty State View
    
    private func emptyStateView(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AIDiagnosisRowCompact: View {
    let diagnosis: AIDiagnosisEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(diagnosis.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(Int(diagnosis.confidencePercentage))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(confidenceColor.opacity(0.2))
                    .foregroundColor(confidenceColor)
                    .cornerRadius(4)
            }
            
            HStack {
                Text(diagnosis.parcelName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(diagnosis.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Técnico: \(diagnosis.technicianName)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(diagnosis.primaryDeficiency)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(diagnosis.detectionState.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(stateColor.opacity(0.2))
                    .foregroundColor(stateColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
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
}

#Preview {
    DiagnosticView()
}
