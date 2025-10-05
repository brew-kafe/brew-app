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
                .padding(.horizontal, -16)
            
            // Report Content
            VStack(alignment: .leading, spacing: 8) {
                // Status and Parcel Name
                HStack(spacing: 8) {
                    Image(systemName: report.statusIcon)
                        .foregroundColor(report.statusSwiftUIColor)
                        .font(.system(size: 20))
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.parcelName)
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        
                        Text(report.diagnosis)
                            .font(.caption)
                            .foregroundColor(report.statusSwiftUIColor)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Timestamp
                Text(report.timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 180)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
