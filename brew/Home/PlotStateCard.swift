//
//  PlotStateCard.swift
//  brew
//
//  Created by Monserrath Valenzuela on 11/09/25.
//

import SwiftUI
import Charts

// MARK: - Modelo de Datos de Parcela
struct PlotState: Identifiable {
    let id = UUID()
    let name: String
    let plots: Int
}

// MARK: - Función para asignar color según estado
func colorStatus(_ status: String) -> Color {
    switch status {
    case "Sana":
        return .green
    case "Enferma":
        return .red
    case "En riesgo":
        return .yellow
    default:
        return .gray
    }
}

// MARK: - PlotStateChart Component
struct PlotStateChart: View {
    @State private var displayPlotState = false
    @State private var animatedValues: [Double]
    
    let data: [PlotState]
    let title: String
    
    init(data: [PlotState]? = nil, title: String = "Mis Parcelas") {
        let defaultData = [
            PlotState(name: "Sana", plots: 8),
            PlotState(name: "Enferma", plots: 2),
            PlotState(name: "En riesgo", plots: 3)
        ]
        
        self.data = data ?? defaultData
        self.title = title
        self._animatedValues = State(initialValue: Array(repeating: 0.0, count: self.data.count))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Título de la sección
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, -20)
            
            // Contenido del gráfico
            HStack(spacing: 24) {
                // MARK: - Chart Dona ANIMADO
                Chart {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, activity in
                        SectorMark(
                            angle: .value("Parcelas", animatedValues[index]),
                            innerRadius: .ratio(0.6),
                            angularInset: 4
                        )
                        .foregroundStyle(colorStatus(activity.name))
                        .cornerRadius(10)
                    }
                }
                .frame(width: 120, height: 120)
                .shadow(radius: 1, x: 0, y: 2)
                .onAppear {
                    // Iniciar la animación cuando aparece la vista
                    withAnimation(.easeInOut(duration: 1.5).delay(0.2)) {
                        for index in 0..<data.count {
                            animatedValues[index] = Double(data[index].plots)
                        }
                    }
                }
                
                // MARK: - Leyenda ANIMADA
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, activity in
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(colorStatus(activity.name))
                                .frame(width: 16, height: 16)
                                .cornerRadius(3)
                                .scaleEffect(displayPlotState ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.2 + 0.5), value: displayPlotState)
                            
                            Text("\(activity.name)")
                                .font(.body)
                                .fontWeight(.medium)
                                .opacity(displayPlotState ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.2 + 0.7), value: displayPlotState)
                            
                            Spacer()
                            
                            Text("(\(activity.plots))")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .opacity(displayPlotState ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.2 + 0.9), value: displayPlotState)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear {
                    // Activar las animaciones de la leyenda
                    withAnimation {
                        displayPlotState = true
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}

#Preview {
    VStack(spacing: 20) {
        PlotStateChart()
        
        // Ejemplo con datos personalizados
        PlotStateChart(
            data: [
                PlotState(name: "Sana", plots: 15),
                PlotState(name: "Enferma", plots: 1),
                PlotState(name: "En riesgo", plots: 2)
            ],
            title: "Estado de Invernaderos"
        )
    }
    .padding()
}
