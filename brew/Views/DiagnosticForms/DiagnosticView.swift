//
//  DiagnosticView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI

struct DiagnosticView: View {
    @StateObject var viewModel = DiagnosisViewModel()
    @State private var showCamera = false
    @State private var selectedDiagnosis: DiagnosisEntity?
    @State private var showingDeleteAlert = false
    @State private var diagnosisToDelete: DiagnosisEntity?

    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                if viewModel.diagnoses.isEmpty {
                    emptyStateView
                } else {
                    diagnosisList
                }

                // Analyzing overlay
                if viewModel.isAnalyzing {
                    analyzingOverlay
                }
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
                CameraView(diagnosisViewModel: viewModel)
            }
            .sheet(item: $selectedDiagnosis) { diagnosis in
                DiagnosticDetailView(diagnosis: diagnosis, viewModel: viewModel)
            }
            .alert("Eliminar Diagnóstico", isPresented: $showingDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    if let diagnosis = diagnosisToDelete {
                        viewModel.deleteDiagnosis(diagnosis)
                    }
                }
            } message: {
                Text("¿Estás seguro de que deseas eliminar este diagnóstico? Esta acción no se puede deshacer.")
            }
        }
    }

    // MARK: - Diagnosis List

    private var diagnosisList: some View {
        List {
            ForEach(viewModel.diagnoses) { diagnosis in
                DiagnosisRow(diagnosis: diagnosis)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDiagnosis = diagnosis
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            diagnosisToDelete = diagnosis
                            showingDeleteAlert = true
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 70))
                .foregroundColor(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255).opacity(0.5))

            Text("No hay diagnósticos")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Toca el botón de cámara para iniciar\ntu primer diagnóstico de plantas")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Analyzing Overlay

    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Analizando imagen...")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Por favor espera")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255))
            )
        }
    }
}

// MARK: - Diagnosis Row View

private struct DiagnosisRow: View {
    let diagnosis: DiagnosisEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with parcel name and status
            HStack {
                Text(diagnosis.parcelName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundColor(statusColor)

                    Text(diagnosis.detectionState.capitalized)
                        .font(.caption)
                        .foregroundColor(statusColor)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(8)
            }

            // Plant number and date
            HStack {
                Label(diagnosis.plantNumber ?? "N/A", systemImage: "leaf.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Label(formattedDate, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Element count
            if !diagnosis.allElements.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)

                    Text("\(diagnosis.allElements.count) deficiencia(s) detectada(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Description
            if let description = diagnosis.aiDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Technician
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Text(diagnosis.technicianName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Computed Properties

    private var statusIcon: String {
        switch diagnosis.detectionState.lowercased() {
        case "danger": return "exclamationmark.triangle.fill"
        case "moderate": return "exclamationmark.circle.fill"
        case "optimal": return "checkmark.circle.fill"
        default: return "circle.fill"
        }
    }

    private var statusColor: Color {
        switch diagnosis.detectionState.lowercased() {
        case "danger": return .red
        case "moderate": return .orange
        case "optimal": return .green
        default: return .gray
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: diagnosis.diagnosisDate)
    }
}

// MARK: - Preview

#Preview {
    DiagnosticView()
}
