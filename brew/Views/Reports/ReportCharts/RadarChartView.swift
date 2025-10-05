//
//  RadarChartView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI

struct RadarChartView: View {
    let data: [NutritionalData]

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.blue.opacity(0.1))
            .overlay(
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("Gráfico Radar Nutricional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
}
