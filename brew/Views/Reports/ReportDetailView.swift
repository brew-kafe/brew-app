//
//  ReportDetailView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI
import Charts

struct ReportDetailView: View {
    @Binding var report: DetailedReportData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                headerSection
                
                // Status and Basic Info
                statusSection
                
                // Unified Radar Chart
                UnifiedRadarChartView(dataSets: report.radarDataSets)
                
                // AI Analysis and Observations
                analysisSection
                
                // Photos Section
                photosSection
            }
            .padding()
        }
        .navigationTitle("Reporte Detallado")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Compartir") {
                    // Share functionality
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(report.parcelName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(report.plantNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: report.statusIcon)
                    .font(.system(size: 30))
                    .foregroundColor(report.statusSwiftUIColor)
            }
            
            Text("Técnico: \(report.technicianName)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(report.timestamp)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diagnóstico")
                .font(.headline)
            
            Text(report.diagnosis)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(report.statusSwiftUIColor.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Analysis Section
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Observaciones y Recomendaciones")
                .font(.title2)
                .fontWeight(.bold)
            
            // Manual Observations
            VStack(alignment: .leading, spacing: 8) {
                Text("Observaciones del Técnico")
                    .font(.headline)
                
                Text(report.manualObservations)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Photos Section
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evidencia Fotográfica")
                .font(.title2)
                .fontWeight(.bold)
            
            if report.photos.isEmpty {
                Text("No hay fotos disponibles")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(report.photos) { photo in
                        VStack(spacing: 8) {
                            AsyncImage(url: URL(string: photo.url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    )
                            }
                            .frame(height: 120)
                            .cornerRadius(12)
                            .clipped()
                            
                            Text(photo.description)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Soil Property Card
struct SoilPropertyCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ReportDetailView(report: .constant(DetailedReportData.sample))
    }
}
