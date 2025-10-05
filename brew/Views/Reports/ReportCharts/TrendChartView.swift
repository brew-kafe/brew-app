//
//  TrendChartView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI
import Charts

struct TrendChartView: View {
    let trends: [TrendPoint]

    var body: some View {
        Chart(trends, id: \.date) { point in
            LineMark(
                x: .value("Fecha", point.date),
                y: .value("Valor", point.value)
            )
            .interpolationMethod(.catmullRom)
        }
        .frame(height: 250)
        .padding()
    }
}

struct TrendPoint {
    let date: Date
    let value: Double
}
