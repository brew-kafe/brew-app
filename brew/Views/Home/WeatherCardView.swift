//
//  WeatherCardView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 11/09/25.
//

import SwiftUI

// MARK: - Modelo de Datos del Clima
struct WeatherData {
    let temperature: Int
    let condition: String
    let icon: String
    let maxTemp: Int
    let minTemp: Int
    let rainProbability: Int
    
    static let sample = WeatherData(
        temperature: 24,
        condition: "Nublado",
        icon: "cloud.fill",
        maxTemp: 27,
        minTemp: 19,
        rainProbability: 52
    )
}

// MARK: - WeatherCard Component
struct WeatherCard: View {
    let weatherData: WeatherData
    
    init(weatherData: WeatherData = WeatherData.sample) {
        self.weatherData = weatherData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clima")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Divider()
                .padding(.horizontal, -20)
            
            HStack(spacing: 8) {
                // Icono del clima
                Image(systemName: weatherData.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("\(weatherData.temperature)°")
                        .font(.system(size: 36, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                    
                    Text(weatherData.condition)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack {
                        HStack {
                            Text("Max: \(weatherData.maxTemp)")
                                .font(.caption)
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "cloud.rain")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("P: \(weatherData.rainProbability)%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("Min: \(weatherData.minTemp)")
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
    }
}

#Preview {
    HStack(spacing: 16) {
        WeatherCard()
        
        // Ejemplo con datos personalizados
        WeatherCard(weatherData: WeatherData(
            temperature: 28,
            condition: "Soleado",
            icon: "sun.max.fill",
            maxTemp: 32,
            minTemp: 21,
            rainProbability: 10
        ))
    }
    .padding()
}
