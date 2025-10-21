//
//  AdminDashboardView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//  Dashboard para administrador
//

import SwiftUI

struct AdminDashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                }
                .padding(.horizontal)
                
                // Estadísticas generales
                HStack(spacing: 16) {
                    StatCard(
                        number: "47",
                        label: "Técnicos"
                    )
                    
                    StatCard(
                        number: "234",
                        label: "Parcelas"
                    )
                }
                .padding(.horizontal)
                
                // Progreso de tareas
                ProgressCard()
                .padding(.horizontal)
                
                // Gráfica de plagas
                PlagueChartCard()
                    .padding(.horizontal)
                
                // Registro de los reportes
                ReportsCard()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}


// MARK: - Preview
#Preview {
    AdminDashboardView()
}
