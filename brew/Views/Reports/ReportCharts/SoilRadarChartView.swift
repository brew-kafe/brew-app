//
//  SoilRadarChartView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI

struct SoilRadarChartView: View {
    let data: SoilData

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.green.opacity(0.1))
            .overlay(
                VStack {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                    Text("Análisis de Suelo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
}
