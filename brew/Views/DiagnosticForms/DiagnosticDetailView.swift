//
//  DiagnosticDetailView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI

struct DiagnosticDetailView: View {
    let diagnosis: Diagnosis
    @ObservedObject var viewModel: DiagnosisViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo Section
                    if let imageData = diagnosis.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                    }
                    
                    // Overall Health Status
                    HealthStatusCard(health: diagnosis.overallHealth)
                        .padding(.horizontal)
                    
                    // Basic Information
                    InfoSection(diagnosis: diagnosis)
                        .padding(.horizontal)
                    
                    // Nutritional Deficiencies
                    if !diagnosis.nutritionalDeficiencies.isEmpty {
                        DeficienciesSection(deficiencies: diagnosis.nutritionalDeficiencies)
                            .padding(.horizontal)
                    }
                    
                    // Diagnosis Text
                    DiagnosisTextSection(diagnosis: diagnosis.diagnosis)
                        .padding(.horizontal)
                    
                    // Additional Notes
                    if let notes = diagnosis.notes, !notes.isEmpty {
                        NotesSection(notes: notes)
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
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [viewModel.exportDiagnosis(diagnosis)])
            }
        }
    }
}

// MARK: - Health Status Card
struct HealthStatusCard: View {
    let health: PlantHealth
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: health.icon)
                .font(.system(size: 50))
                .foregroundColor(health.color)
            
            Text("Estado General")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(health.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(health.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(health.color.opacity(0.1))
        )
    }
}

// MARK: - Info Section
struct InfoSection: View {
    let diagnosis: Diagnosis
    
    var body: some View {
        VStack(spacing: 16) {
            InfoRow(icon: "map", title: "Parcela", value: diagnosis.parcelName)
            Divider()
            InfoRow(icon: "leaf.fill", title: "Planta", value: diagnosis.plantNumber)
            Divider()
            InfoRow(icon: "person.fill", title: "Técnico", value: diagnosis.technicianName)
            Divider()
            InfoRow(icon: "calendar", title: "Fecha", value: formatDate(diagnosis.date))
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
    let deficiencies: [NutritionalDeficiency]
    
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
    let deficiency: NutritionalDeficiency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(deficiency.nutrient.rawValue)
                            .font(.headline)
                        Text("(\(deficiency.nutrient.symbol))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Text(deficiency.severity.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(deficiency.severity.color)
                            )
                        
                        Text("\(deficiency.plantsAffected) plantas (\(String(format: "%.1f", deficiency.percentage))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Text("Recomendaciones:")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(deficiency.recommendations)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(deficiency.severity.color.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(deficiency.severity.color.opacity(0.3), lineWidth: 1)
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

#Preview {
    DiagnosticDetailView(
        diagnosis: Diagnosis(
            parcelName: "Parcela Norte A",
            plantNumber: "PN-045",
            technicianName: "Juan Pérez",
            diagnosis: "Se detectó deficiencia moderada de nitrógeno.",
            nutritionalDeficiencies: [
                NutritionalDeficiency(
                    nutrient: .nitrogen,
                    severity: .moderate,
                    plantsAffected: 15,
                    percentage: 30.0,
                    recommendations: "Aplicar urea 46%"
                )
            ],
            overallHealth: .fair
        ),
        viewModel: DiagnosisViewModel()
    )
}
