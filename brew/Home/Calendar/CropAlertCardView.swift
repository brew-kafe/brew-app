//
//  CropAlertCardView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 11/09/25.
//

import SwiftUI

// MARK: - Modelo de Alerta
struct CropAlert: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let severity: AlertSeverity
    let timestamp: Date
    
    enum AlertSeverity {
        case low, medium, high, critical
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "checkmark.circle.fill"
            case .medium: return "exclamationmark.triangle.fill"
            case .high: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.octagon.fill"
            }
        }
    }
}

// MARK: - Card de Alertas de Cultivos
struct CropAlertsCard: View {
    let alerts: [CropAlert]
    
    // Datos de ejemplo
    static let sampleAlerts = [
        CropAlert(
            title: "Roya detectada",
            description: "Parcela A - Planta 482",
            severity: .critical,
            timestamp: Date().addingTimeInterval(-3600)
        ),
        CropAlert(
            title: "Riego programado",
            description: "Parcela B - Sector 3",
            severity: .medium,
            timestamp: Date().addingTimeInterval(-7200)
        ),
        CropAlert(
            title: "Cosecha lista",
            description: "Parcela C - Zona Norte",
            severity: .low,
            timestamp: Date().addingTimeInterval(-10800)
        )
    ]
    
    init(alerts: [CropAlert] = sampleAlerts) {
        self.alerts = alerts
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Alertas de Cultivos")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !alerts.isEmpty {
                    Text("\(alerts.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            
            if alerts.isEmpty {
                // Estado vacío
                VStack(spacing: 12) {
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.green.opacity(0.6))
                    
                    Text("No hay alertas")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Todos los cultivos están en buen estado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            } else {
                // Lista de alertas
                VStack(spacing: 12) {
                    ForEach(alerts.prefix(3)) { alert in
                        AlertRow(alert: alert)
                    }
                    
                    if alerts.count > 3 {
                        Button(action: {
                            // Acción para ver todas las alertas
                        }) {
                            HStack {
                                Text("Ver todas las alertas (\(alerts.count))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
        .shadow(radius: 3)
    }
}

// MARK: - Fila de Alerta Individual
struct AlertRow: View {
    let alert: CropAlert
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: alert.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono de severidad
            Image(systemName: alert.severity.icon)
                .font(.title2)
                .foregroundColor(alert.severity.color)
                .frame(width: 24)
            
            // Contenido de la alerta
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(alert.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Timestamp
            Text(timeAgo)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Con alertas
        CropAlertsCard()
        
        // Sin alertas
        CropAlertsCard(alerts: [])
    }
    .background(Color(.systemBackground))
}
