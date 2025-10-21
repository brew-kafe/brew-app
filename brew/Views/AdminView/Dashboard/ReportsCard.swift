//
//  ReportsCard.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//

import SwiftUI


// MARK: - Report Model
struct TechnicianReport: Identifiable {
    let id = UUID()
    let reportId: String // ID único del reporte (ej: "RPT-2024-001")
    let technicianName: String
    let parcelaId: String
    let reportDate: Date
    let reportType: ReportType
    let findings: String? // Hallazgos o notas del reporte
    
    enum ReportType {
        case plagueDetected
        case nutrientDeficiency
        case goodCondition
        
        var icon: String {
            switch self {
            case .plagueDetected: return "ladybug.fill"
            case .nutrientDeficiency: return "exclamationmark.triangle.fill"
            case .goodCondition: return "checkmark.seal.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .plagueDetected: return .red
            case .nutrientDeficiency: return .orange
            case .goodCondition: return .green
            }
        }
        
        var label: String {
            switch self {
            case .plagueDetected: return "Plaga detectada"
            case .nutrientDeficiency: return "Deficiencia nutricional"
            case .goodCondition: return "Buen estado"
            }
        }
    }
    
    // Formato de hora (ej: "14:30")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: reportDate)
    }
    
    // Formato de fecha relativa (ej: "Hace 2 horas", "Hoy", "Ayer")
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(reportDate) {
            let components = calendar.dateComponents([.hour, .minute], from: reportDate, to: now)
            
            if let hours = components.hour, hours > 0 {
                return hours == 1 ? "Hace 1 hora" : "Hace \(hours) horas"
            } else if let minutes = components.minute, minutes > 0 {
                return minutes == 1 ? "Hace 1 minuto" : "Hace \(minutes) minutos"
            } else {
                return "Ahora"
            }
        } else if calendar.isDateInYesterday(reportDate) {
            return "Ayer"
        } else {
            let days = calendar.dateComponents([.day], from: reportDate, to: now).day ?? 0
            return "Hace \(days) días"
        }
    }
    
    // Formato completo de fecha (ej: "20 Oct, 14:30")
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: reportDate)
    }
}

// MARK: - Reports Card
struct ReportsCard: View {
    @State private var showingAllReports = false
    
    // Datos de ejemplo de reportes (ordenados por fecha, más reciente primero)
    let reports: [TechnicianReport] = [
        TechnicianReport(
            reportId: "RPT-2024-156",
            technicianName: "Juan Pérez",
            parcelaId: "L-14",
            reportDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            reportType: .goodCondition,
            findings: "Plantas saludables, crecimiento óptimo, sin signos de plagas"
        ),
        TechnicianReport(
            reportId: "RPT-2024-155",
            technicianName: "María López",
            parcelaId: "B-08",
            reportDate: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
            reportType: .plagueDetected,
            findings: "Presencia de áfidos en hojas inferiores, requiere tratamiento inmediato"
        ),
        TechnicianReport(
            reportId: "RPT-2024-154",
            technicianName: "Carlos Ruiz",
            parcelaId: "C-22",
            reportDate: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            reportType: .nutrientDeficiency,
            findings: "Clorosis en hojas, posible deficiencia de nitrógeno"
        ),
        TechnicianReport(
            reportId: "RPT-2024-153",
            technicianName: "Ana García",
            parcelaId: "A-05",
            reportDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            reportType: .goodCondition,
            findings: "Parcela en condiciones óptimas, riego adecuado"
        ),
        TechnicianReport(
            reportId: "RPT-2024-152",
            technicianName: "Juan Pérez",
            parcelaId: "L-14",
            reportDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            reportType: .plagueDetected,
            findings: "Larvas detectadas en el sustrato, aplicar tratamiento preventivo"
        ),
        TechnicianReport(
            reportId: "RPT-2024-151",
            technicianName: "Carlos Ruiz",
            parcelaId: "B-12",
            reportDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            reportType: .nutrientDeficiency,
            findings: "Deficiencia de hierro evidenciada por amarillamiento intervenal"
        )
    ]
    
    var displayedReports: [TechnicianReport] {
        showingAllReports ? reports : Array(reports.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título con botón "Ver todo"
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reportes Recientes")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Monitoreo de actividades de técnicos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if reports.count > 5 {
                    Button(action: { showingAllReports.toggle() }) {
                        Text(showingAllReports ? "Ver menos" : "Ver todo")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Lista de reportes
            VStack(spacing: 8) {
                ForEach(displayedReports) { report in
                    ReportItemDetailed(report: report)
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

// MARK: - Report Item Detailed
struct ReportItemDetailed: View {
    let report: TechnicianReport
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Icono del tipo de reporte
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [report.reportType.color.opacity(0.8), report.reportType.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: report.reportType.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Info del reporte
                VStack(alignment: .leading, spacing: 4) {
                    // ID del reporte
                    Text(report.reportId)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Técnico y parcela
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        
                        Text(report.technicianName)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        
                        Text(report.parcelaId)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(report.reportType.color)
                    }
                    
                    // Hora del reporte
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                        
                        Text(report.fullDateString)
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        
                        Text("•")
                            .font(.system(size: 8))
                            .foregroundStyle(.tertiary)
                        
                        Text(report.timeAgo)
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
                
                // Badge del tipo de reporte
                VStack(spacing: 4) {
                    Text(report.reportType.label)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(report.reportType.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(report.reportType.color.opacity(0.15))
                        .clipShape(Capsule())
                    
                    // Botón de detalles si hay hallazgos
                    if report.findings != nil {
                        Button(action: { showingDetails.toggle() }) {
                            Image(systemName: showingDetails ? "chevron.up.circle.fill" : "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            // Hallazgos/Notas (expandible)
            if showingDetails, let findings = report.findings {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notas del técnico:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(findings)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: showingDetails)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        ReportsCard()
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}


// MARK: - Preview
#Preview {
    ScrollView {
        ReportsCard()
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}

