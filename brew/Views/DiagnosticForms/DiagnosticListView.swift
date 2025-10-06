//
//  DiagnosticListView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI

struct DiagnosticListView: View {
    @StateObject var viewModel = DiagnosisViewModel()
    @State private var showCamera = false
    @State private var selectedDiagnosis: Diagnosis?
    @State private var showingDeleteAlert = false
    @State private var diagnosisToDelete: Diagnosis?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.diagnoses.isEmpty {
                    EmptyDiagnosisView()
                } else {
                    diagnosisList
                }
                
                if viewModel.isAnalyzing {
                    AnalyzingOverlay()
                }
            }
            .navigationTitle("Diagnósticos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCamera = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255)))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Abrir cámara para diagnóstico")
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView()
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
    
    private var diagnosisList: some View {
        List {
            ForEach(viewModel.diagnoses) { diagnosis in
                DiagnosisRowView(diagnosis: diagnosis)
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
}

// MARK: - Diagnosis Row View
struct DiagnosisRowView: View {
    let diagnosis: Diagnosis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(diagnosis.parcelName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: diagnosis.overallHealth.icon)
                        .font(.system(size: 14))
                        .foregroundColor(diagnosis.overallHealth.color)
                    
                    Text(diagnosis.overallHealth.rawValue)
                        .font(.caption)
                        .foregroundColor(diagnosis.overallHealth.color)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(diagnosis.overallHealth.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack {
                Label(diagnosis.plantNumber, systemImage: "leaf.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(dateFormatter.string(from: diagnosis.date), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !diagnosis.nutritionalDeficiencies.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("\(diagnosis.nutritionalDeficiencies.count) deficiencia(s) detectada(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(diagnosis.diagnosis)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
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
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.locale = Locale(identifier: "es_MX")
        return df
    }
}

// MARK: - Empty State View
struct EmptyDiagnosisView: View {
    var body: some View {
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
}

// MARK: - Analyzing Overlay
struct AnalyzingOverlay: View {
    var body: some View {
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

#Preview {
    DiagnosticListView()
}
