//
//  ReportsView.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import SwiftUI

struct ReportsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var vm: ReportViewModel
    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 15) {
                // Encabezado con título
                HStack {
                    Text("Reportes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical)

                Text("Consulta el estado de las parcelas y los reportes más recientes.")
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .padding(.horizontal)

                // Estadísticas rápidas
                ReportStatsRow(reports: filteredReports)
                    .padding(.horizontal)

                // Barra de búsqueda
                SearchBar(text: $searchText)
                    .padding(.horizontal)

                // Lista principal
                List {
                    ForEach(Array(filteredReports.enumerated()), id: \.element.id) { index, report in
                        NavigationLink(destination: ReportDetailView(report: .constant(vm.reports[index]))) {
                            ReportRowView(report: report)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    }
                    .onDelete(perform: deleteReports)
                }
                .scrollContentBackground(.hidden)
                .background(colorScheme == .dark ? Color(.systemBackground) : Color.white)
                .refreshable {
                    vm.refreshReports()
                }
            }
        }
    }
    
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.4, green: 0.35, blue: 0.1).opacity(0.6),
                Color(red: 0.3, green: 0.25, blue: 0.1).opacity(0.8)
            ]
        } else {
            return [
                Color.yellow.opacity(0.3),
                Color.brown.opacity(0.50)
            ]
        }
    }

    private var filteredReports: [DetailedReportData] {
        if searchText.isEmpty {
            return vm.reports
        }
        return vm.reports.filter { report in
            report.parcelName.localizedCaseInsensitiveContains(searchText) ||
            report.diagnosis.localizedCaseInsensitiveContains(searchText) ||
            report.technicianName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func deleteReports(offsets: IndexSet) {
        for index in offsets {
            vm.deleteReport(vm.reports[index])
        }
    }
}

// MARK: - Report Stats Row
struct ReportStatsRow: View {
    @Environment(\.colorScheme) var colorScheme
    let reports: [DetailedReportData]
    
    private var healthyCount: Int {
        reports.filter { $0.statusIcon == "checkmark.circle.fill" }.count
    }
    
    private var warningCount: Int {
        reports.filter { $0.statusIcon == "exclamationmark.triangle.fill" }.count
    }
    
    private var criticalCount: Int {
        reports.filter { $0.statusIcon == "xmark.octagon.fill" }.count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            StatBadge(count: healthyCount, label: "Sanos", color: .green)
            StatBadge(count: warningCount, label: "Riesgo", color: .orange)
            StatBadge(count: criticalCount, label: "Críticos", color: .red)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    @Environment(\.colorScheme) var colorScheme
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar reportes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Enhanced Report Row View
struct ReportRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let report: DetailedReportData
    
    var body: some View {
        HStack(spacing: 12) {
            // Ícono de estado con círculo de fondo
            ZStack {
                Circle()
                    .fill(report.statusSwiftUIColor.opacity(colorScheme == .dark ? 0.25 : 0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: report.statusIcon)
                    .font(.system(size: 20))
                    .foregroundColor(report.statusSwiftUIColor)
            }
            
            // Información del reporte
            VStack(alignment: .leading, spacing: 5) {
                Text(report.parcelName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .lineLimit(1)
                
                Text(report.diagnosis)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 11))
                        Text(report.technicianName)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                        Text(report.timestamp)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                }
            }
            
            Spacer()
            
            // Chevron con fondo sutil
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    ReportsView()
        .environmentObject(ReportViewModel())
        .preferredColorScheme(.dark)
}
