//
//  NutritionalChartView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI
import Charts

struct NutritionalChartView: View {
    let data: [NutritionalData]

    var body: some View {
        Chart(data, id: \.nutrient) { item in
            BarMark(
                x: .value("Nutrient", item.nutrient),
                y: .value("Symptoms %", item.symptomsPercentage)
            )
            .foregroundStyle(by: .value("Weight", item.weightingValue))
        }
        .chartLegend(.visible)
        .frame(height: 250)
        .padding()
    }
}
