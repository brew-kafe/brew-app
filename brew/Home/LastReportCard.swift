//
//  LastReportCard.swift
//  brew
//
//  Created by Monserrath Valenzuela on 11/09/25.
//

import SwiftUI

// MARK: - Modelo de Datos del Reporte
struct ReportData {
    let parcelName: String
    let plantNumber: String
    let diagnosis: String
    let condition: String
    let timestamp: String
    let icon: String
    let iconColor: Color
    let conditionColor: Color
    
    static let sample = ReportData(
        parcelName: "Parcela A",
        plantNumber: "Planta 482",
        diagnosis: "Diagnóstico:",
        condition: "con roya",
        timestamp: "10:21am | Sep 8, 2025",
        icon: "folder.fill",
        iconColor: .orange,
        conditionColor: .red
    )
}

// MARK: - LastReportCard Component
struct LastReportCard: View {
    let reportData: ReportData
    
    init(reportData: ReportData = ReportData.sample) {
        self.reportData = reportData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Último reporte")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Divider()
                .padding(.horizontal, -20)
                .padding(.bottom, 5)
            
            HStack(spacing: 12) {
                // Icono de carpeta
                Image(systemName: reportData.icon)
                    .font(.system(size: 32))
                    .foregroundColor(reportData.iconColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reportData.parcelName)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text(reportData.plantNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(reportData.diagnosis)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(reportData.condition)
                        .font(.caption)
                        .foregroundColor(reportData.conditionColor)
                }
            }
            
            Spacer() // Para empujar el contenido hacia arriba
            
            HStack(spacing: 0) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(reportData.timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 180)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

#Preview {
    HStack(spacing: 16) {
        LastReportCard()
        
        // Ejemplo con datos personalizados
        LastReportCard(reportData: ReportData(
            parcelName: "Parcela B",
            plantNumber: "Planta 203",
            diagnosis: "Estado:",
            condition: "saludable",
            timestamp: "2:15pm | Sep 9, 2025",
            icon: "folder.fill",
            iconColor: .green,
            conditionColor: .green
        ))
    }
    .padding()
}
