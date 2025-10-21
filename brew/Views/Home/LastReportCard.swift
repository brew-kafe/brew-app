//
//  LastReportCard.swift
//  brew
//
//  Created by Monserrath Valenzuela on 11/09/25.
//

import SwiftUI

struct LastReportCard: View {
    let report: DetailedReportData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("Parcela")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Divider()
                .padding(.horizontal, -16)   // mismo ancho que la tarjeta

            // Report Content
            VStack(alignment: .leading, spacing: 8) {
                // Status and Parcel Name
                HStack(spacing: 8) {
                    Image(systemName: report.statusIcon)
                        .foregroundColor(report.statusSwiftUIColor)
                        .font(.system(size: 20))
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        // Permitir 2 líneas para el nombre de la parcela
                        Text(report.parcelName)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(2) // da prioridad a este texto para que no lo compriman

                        // Permitir más líneas para el diagnóstico (p.ej. 3)
                        Text(report.diagnosis)
                            .font(.caption)
                            .foregroundColor(report.statusSwiftUIColor)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                    }

                    // No forzamos compresión con un Spacer grande
                    Spacer(minLength: 0)
                }

                Spacer(minLength: 0)

                // Timestamp
                Text(report.timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        // Quitamos maxHeight para que pueda crecer si hay más texto;
        //
        .frame(maxWidth: .infinity, minHeight: 190)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
