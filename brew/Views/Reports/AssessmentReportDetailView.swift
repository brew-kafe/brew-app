//
//  AssessmentReportDetailView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI

struct AssessmentReportDetailView: View {
    let report: AssessmentReport

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(report.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Fecha: \(report.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                Text(report.description)
                    .font(.body)

                if !report.images.isEmpty {
                    Text("Evidencia fotográfica:")
                        .font(.headline)
                    ForEach(report.images, id: \.self) { imageURL in
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image.resizable().scaledToFit().cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Reporte de Evaluación")
        .navigationBarTitleDisplayMode(.inline)
    }
}
