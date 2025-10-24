//
//  DiagnosticDetailView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI

struct DiagnosticDetailView: View {
    let diagnosis: DiagnosisEntity
    @ObservedObject var viewModel: DiagnosisViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    @State private var shareSheet: ShareSheet?
    
    var body: some View {
        NavigationView {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // Image section - using photoURLs array
                if let firstPhotoURL = diagnosis.photoURLs.first,
                   let url = URL(string: firstPhotoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                    }
                    .frame(maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                }
                
                // Overall Health Status
                HealthStatusCard(detectionState: diagnosis.detectionState)
                    .padding(.horizontal)
                
                // Basic Information
                InfoSection(diagnosis: diagnosis)
                    .padding(.horizontal)
                
                // Nutritional Deficiencies  
                if !diagnosis.allElements.isEmpty {
                    DeficienciesSection(deficiencies: diagnosis.allElements)
                            .padding(.horizontal)
                    }
                    
                    // Diagnosis Text
                    DiagnosisTextSection(diagnosis: diagnosis.aiDescription ?? "No description available")
                        .padding(.horizontal)
                    
                    // Additional Notes - using recommendations instead
                    if !diagnosis.aiRecommendations.isEmpty {
                        NotesSection(notes: diagnosis.aiRecommendations.joined(separator: "\n"))
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Detalle del Diagnóstico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(action: {
                            // Create a simple diagnosis export string
                            let exportData = """
                            Diagnóstico de Planta
                            
                            Parcela: \(diagnosis.parcelName)
                            Planta: \(diagnosis.plantNumber ?? "N/A")
                            Técnico: \(diagnosis.technicianName)
                            Deficiencia: \(diagnosis.primaryDeficiency)
                            Estado: \(diagnosis.detectionState)
                            Fecha: \(DateFormatter.localizedString(from: diagnosis.diagnosisDate, dateStyle: .medium, timeStyle: .short))
                            
                            Recomendaciones:
                            \(diagnosis.aiRecommendations.joined(separator: "\n"))
                            """
                            
                            shareSheet = ShareSheet(items: [exportData])
                            showShareSheet = true
                        }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let sheet = shareSheet {
                    sheet
                }
            }
        }
    }
}

// MARK: - Health Status Card
struct HealthStatusCard: View {
    let detectionState: String
    
    private func getHealthIcon(for state: String) -> String {
        switch state.lowercased() {
        case "danger", "crítico": return "exclamationmark.triangle.fill"
        case "moderate", "moderado": return "exclamationmark.circle.fill"
        case "optimal", "óptimo": return "checkmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func getHealthColor(for state: String) -> Color {
        switch state.lowercased() {
        case "danger", "crítico": return .red
        case "moderate", "moderado": return .orange
        case "optimal", "óptimo": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: getHealthIcon(for: detectionState))
                .font(.system(size: 50))
                .foregroundColor(getHealthColor(for: detectionState))
            
            Text("Estado General")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(detectionState.capitalized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(getHealthColor(for: detectionState))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(getHealthColor(for: detectionState).opacity(0.1))
        )
    }
}

// MARK: - Info Section
struct InfoSection: View {
    let diagnosis: DiagnosisEntity
    
    var body: some View {
        VStack(spacing: 16) {
            InfoRow(icon: "map", title: "Parcela", value: diagnosis.parcelName)
            Divider()
            InfoRow(icon: "leaf.fill", title: "Planta", value: diagnosis.plantNumber ?? "N/A")
            Divider()
            InfoRow(icon: "person.fill", title: "Técnico", value: diagnosis.technicianName)
            Divider()
            InfoRow(icon: "calendar", title: "Fecha", value: formatDate(diagnosis.diagnosisDate))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Deficiencies Section
struct DeficienciesSection: View {
    let deficiencies: [ElementAnalysis]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Deficiencias Detectadas")
                    .font(.headline)
            }
            
            ForEach(deficiencies) { deficiency in
                DeficiencyCard(deficiency: deficiency)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Deficiency Card
struct DeficiencyCard: View {
    let deficiency: ElementAnalysis
    
    private func getDetectionColor(for state: String) -> Color {
        switch state.lowercased() {
        case "danger", "critical", "crítico":
            return .red
        case "moderate", "moderado":
            return .orange
        case "optimal", "óptimo":
            return .green
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deficiency.element)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text(detectionStateDisplayName(deficiency.detectionState))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(getDetectionColor(for: deficiency.detectionState))
                            )
                        
                        Text("\(String(format: "%.1f", deficiency.percentage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            if let deficiencyLevel = deficiency.deficiencyLevel {
                Text("Nivel: \(deficiencyLevel)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            if !deficiency.recommendations.isEmpty {
                Text("Recomendaciones:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ForEach(deficiency.recommendations, id: \.self) { recommendation in
                    Text("• \(recommendation)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(getDetectionColor(for: deficiency.detectionState).opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(getDetectionColor(for: deficiency.detectionState).opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Diagnosis Text Section
struct DiagnosisTextSection: View {
    let diagnosis: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255))
                Text("Diagnóstico")
                    .font(.headline)
            }
            
            Text(diagnosis)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Notes Section
struct NotesSection: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.secondary)
                Text("Notas Adicionales")
                    .font(.headline)
            }
            
            Text(notes)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Helper Functions
private func detectionStateDisplayName(_ state: String) -> String {
    switch state.lowercased() {
    case "danger", "critical", "crítico":
        return "Crítico"
    case "moderate", "moderado":
        return "Moderado"
    case "optimal", "óptimo":
        return "Óptimo"
    default:
        return state.capitalized
    }
}

#Preview {
    DiagnosticDetailView(
        diagnosis: DiagnosisEntity(
            parcelName: "Parcela Norte A",
            plantNumber: "PN-045",
            technicianName: "Juan Pérez",
            primaryDeficiency: "Nitrogen Deficiency",
            deficiencyElement: "Nitrogen",
            detectionState: "CONFIRMED",
            aiConfidence: 0.85,
            aiDescription: "Se detectó deficiencia moderada de nitrógeno.",
            aiRecommendations: ["Aplicar urea 46%"],
            allElements: [
                ElementAnalysis(
                    element: "Nitrogen", 
                    percentage: 85.0, 
                    detectionState: "moderate", 
                    deficiencyLevel: "Moderate", 
                    recommendations: ["Aplicar urea 46%"]
                )
            ],
            photoURLs: [],
            diagnosisDate: Date(),
            createdAt: Date()
        ),
        viewModel: DiagnosisViewModel()
    )
}
