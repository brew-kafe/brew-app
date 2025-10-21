//
//  ProgressCard.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//
//
//  AdminDashboardView.swift
//  brew
//
//  Dashboard para administrador
//

import SwiftUI

// MARK: - Progress Card Component
struct ProgressCard: View {
    // Datos de tareas
    let inProgress = 8
    let completed = 12
    let upcoming = 14
    
    var totalTasks: Int {
        inProgress + completed + upcoming
    }
    
    var completionPercentage: Int {
        guard totalTasks > 0 else { return 0 }
        return Int((Double(completed) / Double(totalTasks)) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título
            Text("Estadísticas de Progreso")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Porcentaje de completadas
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(completionPercentage)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            
            Text("Tareas Completadas")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            // Barra de progreso (solo muestra completadas)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    // Progreso (solo verde para completadas)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 48/255, green: 209/255, blue: 88/255))
                        .frame(width: geometry.size.width * CGFloat(completionPercentage) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            // Estadísticas por estado
            HStack(spacing: 12) {
                ProgressStatItem(
                    icon: "clock.fill",
                    iconColor: Color(red: 94/255, green: 92/255, blue: 230/255),
                    iconBackground: Color(red: 227/255, green: 224/255, blue: 255/255),
                    count: "\(inProgress)",
                    label: "En progreso"
                )
                
                ProgressStatItem(
                    icon: "checkmark",
                    iconColor: Color(red: 48/255, green: 209/255, blue: 88/255),
                    iconBackground: Color(red: 209/255, green: 244/255, blue: 224/255),
                    count: "\(completed)",
                    label: "Completadas"
                )
                
                ProgressStatItem(
                    icon: "calendar",
                    iconColor: Color(red: 255/255, green: 159/255, blue: 10/255),
                    iconBackground: Color(red: 255/255, green: 229/255, blue: 208/255),
                    count: "\(upcoming)",
                    label: "Próximas"
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Progress Stat Item
struct ProgressStatItem: View {
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let count: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Ícono circular
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Número
            Text(count)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            // Etiqueta
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(number)
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    ProgressCard()
}
