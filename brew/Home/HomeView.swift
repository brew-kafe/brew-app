//
//  HomeView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 10/09/25.
//

import SwiftUI
import Charts


struct HomeView: View  {
    var body: some View {
        NavigationStack {
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
                    PlotStateChart()
                        .padding(.horizontal, 20)
                    
                    // MARK: - Cards Row (Clima y Último Reporte)
                    HStack(spacing: 16) {
                        WeatherCard()
                        LastReportCard()
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Calendario
                    CalendarWidgetView()
                    
                    
                    // MARK: - Card de Alertas
                    CropAlertsCard()
                    
                    //MARK: Card de Recomendaciones
                    CropRecommendationsCard()
                        .shadow(radius: 3)
                    
                    
                }
                .background(Color(.systemBackground))
            }
        }
    }
}

#Preview {
    HomeView()
}
