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
    
    let data = [
        PlotState(name:"Sana", plots: 8),
        PlotState(name:"Enferma", plots: 2),
        PlotState(name:"En riesgo", plots: 3)
    ]
    
    var body: some View {
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
                    // MARK: - Chart Dona
                    Chart {
                        ForEach(data) { activity in
                            SectorMark(
                                angle: .value("Parcelas", activity.plots),
                                innerRadius: .ratio(0.6),
                                angularInset: 4
                            )
                            .foregroundStyle(colorStatus(activity.name))
                            .cornerRadius(10)
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    // MARK: - Leyenda
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(data) { activity in
                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(colorStatus(activity.name))
                                    .frame(width: 16, height: 16)
                                    .cornerRadius(3)
                                
                                Text("\(activity.name)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("(\(activity.plots))")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 4)
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            //Mark: Cards Row (Weather, Last Report)
            HStack(spacing: 16) {
                           // MARK: - Weather Card
                           VStack(alignment: .leading, spacing: 12) {
                                Text("Clima")
                                    .font(.title3 )
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                               //Image (systemName: "chevron.right")
                               
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
                                               HStack{
                                                   Image(systemName: "cloud.rain")
                                                       .font(.caption)
                                                       .foregroundColor(.secondary)
                                                   
                                                   Text("P: 52%")
                                                       .font(.caption)
                                                       .foregroundColor(.secondary)
                                               }
                                           }
                                           
                                           Spacer()
                                           
                                           HStack{
                                               
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
                           
                           // MARK: - Last Report Card
                           VStack(alignment: .leading, /*spacing: 12*/) {
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
                               
                               HStack(spacing:0){
                                   
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
                       }
                       .padding(.horizontal, 20)
            Spacer()
            
            
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    HomeView()
}

