//
//  UnifiedRadarChartView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI
import Charts

struct UnifiedRadarChartView: View {
    let dataSets: [RadarChartDataSet]
    @State private var selectedType: AnalysisType
    @State private var animationProgress: Double = 0.0
    
    // Computed property for current dataset
    private var currentDataSet: RadarChartDataSet {
        dataSets.first { $0.type == selectedType } ?? dataSets.first ?? RadarChartDataSet.nutritionalSample
    }
    
    init(dataSets: [RadarChartDataSet]) {
        self.dataSets = dataSets
        self._selectedType = State(initialValue: dataSets.first?.type ?? .nutritional)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with type selector
            headerSection
            
            // Radar Chart
            radarChartSection
            
            // Legend and Stats
            legendSection
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
        .onChange(of: selectedType) { _, _ in
            // Reset and restart animation when type changes
            animationProgress = 0.0
            withAnimation(.easeInOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Análisis Detallado")
                .font(.title2)
                .fontWeight(.bold)
            
            // Type Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dataSets, id: \.type.rawValue) { dataSet in
                        Button(action: {
                            selectedType = dataSet.type
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: dataSet.type.icon)
                                    .font(.system(size: 14))
                                Text(dataSet.type.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedType == dataSet.type ? 
                                dataSet.type.color.opacity(0.2) : Color(.systemGray6)
                            )
                            .foregroundColor(
                                selectedType == dataSet.type ? 
                                dataSet.type.color : .secondary
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        selectedType == dataSet.type ? 
                                        dataSet.type.color : Color.clear, 
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
        }
    }
    
    // MARK: - Radar Chart Section
    private var radarChartSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background grid
                RadarGridView(numberOfRings: 5)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                
                // Data visualization
                RadarPolygonView(
                    dataPoints: currentDataSet.dataPoints,
                    color: currentDataSet.type.color,
                    animationProgress: animationProgress
                )
                
                // Labels around the radar
                RadarLabelsView(dataPoints: currentDataSet.dataPoints)
            }
            .frame(width: 320, height: 320)
            .padding()
            
            // Overall Score
            HStack(spacing: 16) {
                VStack {
                    Text("Puntuación General")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(currentDataSet.overallScore * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(currentDataSet.type.color)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("Estado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(healthStatus(currentDataSet.overallScore))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(healthStatusColor(currentDataSet.overallScore))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Legend Section
    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detalles")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(currentDataSet.dataPoints) { point in
                    VStack(spacing: 4) {
                        HStack {
                            Text(point.label)
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            Spacer()
                            Text("\(Int(point.normalizedValue * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: point.normalizedValue * animationProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: currentDataSet.type.color))
                            .scaleEffect(y: 0.8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Functions
    private func healthStatus(_ score: Double) -> String {
        switch score {
        case 0.8...: return "Excelente"
        case 0.6..<0.8: return "Bueno"
        case 0.4..<0.6: return "Regular"
        case 0.2..<0.4: return "Malo"
        default: return "Crítico"
        }
    }
    
    private func healthStatusColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        case 0.2..<0.4: return .red
        default: return .red
        }
    }
}

// MARK: - Radar Grid View
struct RadarGridView: Shape {
    let numberOfRings: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Draw concentric circles
        for i in 1...numberOfRings {
            let ringRadius = radius * CGFloat(i) / CGFloat(numberOfRings)
            path.addEllipse(in: CGRect(
                x: center.x - ringRadius,
                y: center.y - ringRadius,
                width: ringRadius * 2,
                height: ringRadius * 2
            ))
        }
        
        return path
    }
}

// MARK: - Radar Polygon View
struct RadarPolygonView: View {
    let dataPoints: [RadarDataPoint]
    let color: Color
    let animationProgress: Double
    
    var body: some View {
        ZStack {
            // Fill
            RadarPolygonShape(dataPoints: dataPoints, animationProgress: animationProgress)
                .fill(color.opacity(0.3))
            
            // Stroke
            RadarPolygonShape(dataPoints: dataPoints, animationProgress: animationProgress)
                .stroke(color, lineWidth: 2)
            
            // Data points
            ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, point in
                let angle = angleForIndex(index, total: dataPoints.count)
                let radius = min(160, 160) * point.normalizedValue * animationProgress
                let position = positionForAngle(angle, radius: radius, center: CGPoint(x: 160, y: 160))
                
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .position(position)
            }
        }
    }
    
    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let angleStep = 2 * Double.pi / Double(total)
        return Double(index) * angleStep - Double.pi / 2 // Start from top
    }
    
    private func positionForAngle(_ angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        return CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )
    }
}

// MARK: - Radar Polygon Shape
struct RadarPolygonShape: Shape {
    let dataPoints: [RadarDataPoint]
    let animationProgress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2
        
        guard !dataPoints.isEmpty else { return path }
        
        let angleStep = 2 * Double.pi / Double(dataPoints.count)
        
        for (index, point) in dataPoints.enumerated() {
            let angle = Double(index) * angleStep - Double.pi / 2
            let radius = maxRadius * point.normalizedValue * animationProgress
            let position = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            if index == 0 {
                path.move(to: position)
            } else {
                path.addLine(to: position)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Radar Labels View
struct RadarLabelsView: View {
    let dataPoints: [RadarDataPoint]
    
    var body: some View {
        ZStack {
            ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, point in
                let angle = angleForIndex(index, total: dataPoints.count)
                let labelRadius: Double = 180 // Position labels outside the chart for 9 nutrients
                let position = positionForAngle(angle, radius: labelRadius, center: CGPoint(x: 160, y: 160))
                
                Text(point.displayLabel)
                    .font(.system(size: 10, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .frame(width: 55, height: 25)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemBackground).opacity(0.8))
                    )
                    .position(position)
            }
        }
    }
    
    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let angleStep = 2 * Double.pi / Double(total)
        return Double(index) * angleStep - Double.pi / 2
    }
    
    private func positionForAngle(_ angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        return CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        UnifiedRadarChartView(dataSets: [
            RadarChartDataSet.nutritionalSample,
            RadarChartDataSet.soilSample,
            RadarChartDataSet.healthSample
        ])
        .padding()
    }
}
