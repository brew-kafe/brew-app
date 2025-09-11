//
//  HomeView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 10/09/25.
//

import SwiftUI
import Charts

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

struct HomeView: View  {
    @State private var displayPlotState = false
    @State private var animatedValues: [Double] = [0, 0, 0] // Para la animación
    
    let data = [
        PlotState(name:"Sana", plots: 8),
        PlotState(name:"Enferma", plots: 2),
        PlotState(name:"En riesgo", plots: 3)
    ]
    
    let weekDays = [ "D", "L", "M", "M", "J", "V", "S"]
    let days = Array(8...14)
        
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Header
                HStack {
                    Text("Inicio")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image("")
                        .resizable()
                        .scaledToFit()
                        .background(Color.yellow)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // MARK: - Card "Mis Parcelas"
                VStack(spacing: 16) {
                    // Título de la sección
                    HStack {
                        Text("Mis Parcelas")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal,-20)
                    
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
                .padding(.horizontal, 20)
                .shadow(radius: 3)
                
                //Mark: Cards Row (Weather, Last Report)
                HStack(spacing: 16) {
                    // MARK: - Weather Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Clima")
                            .font(.title3 )
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Divider()
                            .padding(.horizontal, -20)
                        
                        HStack (spacing:8) {
                            // Icono del clima
                            Image(systemName: "cloud.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("24°")
                                    .font(.system(size: 36, weight: .bold))
                                    .monospacedDigit()
                                    .foregroundColor(.primary)
                                
                                Text("Nublado")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                VStack {
                                    HStack {
                                        Text("Max: 27")
                                            .font(.caption)
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Image(systemName: "cloud.rain")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("P: 52%")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    HStack () {
                                        Text("Min: 19")
                                            .font(.caption)
                                        Spacer()
                                    }
                                    
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 180)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    
                    // MARK: - Last Report Card
                    VStack(alignment: .leading) {
                        Text("Último reporte")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Divider()
                            .padding(.horizontal, -20)
                            .padding(.bottom, 5)
                        
                        HStack(spacing: 12) {
                            // Icono de carpeta
                            Image(systemName: "folder.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Parcela A")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
                                Text("Planta 482")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Diagnóstico:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("con roya")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Spacer() // Para empujar el contenido hacia arriba
                        
                        HStack(spacing:0) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("10:21am | Sep 8, 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame (maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 180)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
                .padding(.horizontal, 20)
                
                // MARK: - Calendario
                CalendarView(
                    monthName: "Septiembre",
                    days: [8, 9, 10, 11, 12, 13, 14]
                ) { selectedDay in
                    print("Día seleccionado: \(selectedDay)")
                    
                            }
                
                
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    HomeView()
}
