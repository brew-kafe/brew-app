//
//  PlagueChartCard.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//

import SwiftUI

// MARK: - Plague Chart Card
struct PlagueChartCard: View {
    // Datos de ejemplo: plagas identificadas por mes
    let monthlyData: [(month: String, count: Int)] = [
        ("Ene", 5),
        ("Feb", 8),
        ("Mar", 12),
        ("Abr", 15),
        ("May", 11),
        ("Jun", 7),
        ("Jul", 9),
        ("Ago", 14),
        ("Sep", 10),
        ("Oct", 6),
        ("Nov", 4),
        ("Dic", 3)
    ]
    
    var maxValue: Int {
        let max = monthlyData.map { $0.count }.max() ?? 15
        // Redondear al siguiente múltiplo de 5 para los contadores
        return ((max + 4) / 5) * 5
    }
    
    var yAxisSteps: [Int] {
        let step = maxValue / 5
        return stride(from: 0, through: maxValue, by: step).reversed().map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título
            VStack(alignment: .leading, spacing: 4) {
                Text("Estadística de Plagas")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Plagas identificadas en reportes mensuales")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Gráfica de líneas con eje Y
            HStack(spacing: 8) {
                // Eje Y (contadores)
                VStack(spacing: 0) {
                    ForEach(yAxisSteps, id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .frame(height: 180 / CGFloat(yAxisSteps.count - 1), alignment: .top)
                        
                        if value != yAxisSteps.last {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(width: 20)
                
                // Área de la gráfica
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottomLeading) {
                            // Líneas de fondo horizontales
                            VStack(spacing: 0) {
                                ForEach(0..<yAxisSteps.count - 1) { _ in
                                    Divider()
                                        .background(Color(.systemGray5))
                                    Spacer()
                                }
                            }
                            
                            // Área bajo la línea (gradiente)
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let stepX = width / CGFloat(monthlyData.count - 1)
                                
                                path.move(to: CGPoint(x: 0, y: height))
                                
                                for (index, data) in monthlyData.enumerated() {
                                    let x = CGFloat(index) * stepX
                                    let y = height - (CGFloat(data.count) / CGFloat(maxValue)) * height
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: height))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 255/255, green: 59/255, blue: 48/255).opacity(0.3),
                                        Color(red: 255/255, green: 59/255, blue: 48/255).opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Línea de la gráfica
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let stepX = width / CGFloat(monthlyData.count - 1)
                                
                                for (index, data) in monthlyData.enumerated() {
                                    let x = CGFloat(index) * stepX
                                    let y = height - (CGFloat(data.count) / CGFloat(maxValue)) * height
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(
                                Color(red: 255/255, green: 59/255, blue: 48/255),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                            
                            // Puntos en la línea
                            ForEach(Array(monthlyData.enumerated()), id: \.offset) { index, data in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let stepX = width / CGFloat(monthlyData.count - 1)
                                let x = CGFloat(index) * stepX
                                let y = height - (CGFloat(data.count) / CGFloat(maxValue)) * height
                                
                                Circle()
                                    .fill(Color(red: 255/255, green: 59/255, blue: 48/255))
                                    .frame(width: 6, height: 6)
                                    .position(x: x, y: y)
                            }
                        }
                    }
                    .frame(height: 180)
                    
                    // Etiquetas de meses
                    HStack(spacing: 0) {
                        ForEach(monthlyData, id: \.month) { data in
                            Text(data.month)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    PlagueChartCard()
}
