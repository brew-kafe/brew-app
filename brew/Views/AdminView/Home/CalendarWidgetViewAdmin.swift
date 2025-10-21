
//
//  CalendarWidgetViewAdmin.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//

import SwiftUI

// MARK: - Technician Task Summary Chip
struct TechnicianTaskSummaryChip: View {
    let task: TechnicianTaskAdmin
    let selectedDate: Date
    
    var isCompleted: Bool {
        task.isCompleted(on: selectedDate)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: task.icon)
                .font(.caption2)
                .foregroundColor(task.color)
            
            Text(task.technicianName)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(task.color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(task.color.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Calendar Widget View Admin
struct CalendarWidgetViewAdmin: View {
    @State private var selectedDate = Date()
    
    let weekDays = ["D", "L", "M", "M", "J", "V", "S"]
    
    // Datos de ejemplo de técnicos y sus tareas
    let technicianTasks: [TechnicianTaskAdmin] = [
        TechnicianTaskAdmin(
            technicianName: "Juan Pérez",
            taskTitle: "Regar",
            taskDescription: "Riego programado de parcelas",
            icon: "drop.fill",
            colorHex: "007AFF",
            assignedDates: [Date(), Calendar.current.date(byAdding: .day, value: 2, to: Date())!],
            completedDates: [Date()],
            parcelaId: "L-14"
        ),
        TechnicianTaskAdmin(
            technicianName: "María López",
            taskTitle: "Control de Plagas",
            taskDescription: "Revisar y tratar plagas",
            icon: "ladybug.fill",
            colorHex: "FF3B30",
            assignedDates: [Date(), Calendar.current.date(byAdding: .day, value: 1, to: Date())!],
            completedDates: [],
            parcelaId: "B-08"
        ),
        TechnicianTaskAdmin(
            technicianName: "Carlos Ruiz",
            taskTitle: "Fertilizar",
            taskDescription: "Aplicar nutrientes a las plantas",
            icon: "speedometer",
            colorHex: "34C759",
            assignedDates: [Date()],
            completedDates: [Date()],
            parcelaId: "C-22"
        ),
        TechnicianTaskAdmin(
            technicianName: "Ana García",
            taskTitle: "Visita al Plot",
            taskDescription: "Inspección del terreno",
            icon: "figure.walk",
            colorHex: "FF9500",
            assignedDates: [Calendar.current.date(byAdding: .day, value: 1, to: Date())!],
            completedDates: [],
            parcelaId: "A-05"
        ),
        TechnicianTaskAdmin(
            technicianName: "Juan Pérez",
            taskTitle: "Podar",
            taskDescription: "Revisar y cortar plantas",
            icon: "eye.fill",
            colorHex: "AF52DE",
            assignedDates: [Calendar.current.date(byAdding: .day, value: 1, to: Date())!],
            completedDates: [],
            parcelaId: "L-14"
        ),
        TechnicianTaskAdmin(
            technicianName: "María López",
            taskTitle: "Fotos de Progreso",
            taskDescription: "Documentar crecimiento",
            icon: "photo.fill",
            colorHex: "FF2D55",
            assignedDates: [Calendar.current.date(byAdding: .day, value: 2, to: Date())!],
            completedDates: [],
            parcelaId: "B-08"
        ),
        TechnicianTaskAdmin(
            technicianName: "Carlos Ruiz",
            taskTitle: "Revisar Humedad",
            taskDescription: "Medir niveles de humedad",
            icon: "humidity.fill",
            colorHex: "32ADE6",
            assignedDates: [Calendar.current.date(byAdding: .day, value: 2, to: Date())!],
            completedDates: [],
            parcelaId: "C-22"
        ),
        TechnicianTaskAdmin(
            technicianName: "Ana García",
            taskTitle: "Exposición Solar",
            taskDescription: "Verificar luz solar",
            icon: "sun.max.fill",
            colorHex: "FFCC00",
            assignedDates: [Calendar.current.date(byAdding: .day, value: 4, to: Date())!],
            completedDates: [],
            parcelaId: "A-05"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con título y botón para ver calendario completo
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calendario Global")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(monthYearString)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: CalendarViewAdmin()) {
                    HStack(spacing: 4) {
                        Text("Ver todo")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color(.systemGray6))
            
            // Grid de la semana
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Días de la semana (encabezados)
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                
                // Días numéricos de la semana actual
                ForEach(currentWeekDays, id: \.self) { date in
                    WeekDayCellAdmin(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        hasTasks: hasTasks(for: date),
                        completedCount: completedTasksCount(for: date),
                        totalCount: totalTasksCount(for: date),
                        onTap: { selectedDate = date }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Indicador de tareas del día seleccionado
            VStack(alignment: .leading, spacing: 8) {
                if totalTasksCount(for: selectedDate) > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("\(completedTasksCount(for: selectedDate)) de \(totalTasksCount(for: selectedDate)) completadas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Resumen de tareas del día (técnicos)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tasksForDate(selectedDate).prefix(4)) { task in
                                TechnicianTaskSummaryChip(
                                    task: task,
                                    selectedDate: selectedDate
                                )
                            }
                            
                            if tasksForDate(selectedDate).count > 4 {
                                Text("+\(tasksForDate(selectedDate).count - 4)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("Sin tareas programadas")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .shadow(radius: 3)
    }
    
    // MARK: - Computed Properties
    
    var currentWeekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = weekInterval.start
        
        for _ in 0..<7 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: selectedDate).capitalized
    }
    
    // MARK: - Helper Functions
    
    func hasTasks(for date: Date) -> Bool {
        return !tasksForDate(date).isEmpty
    }
    
    func tasksForDate(_ date: Date) -> [TechnicianTaskAdmin] {
        technicianTasks.filter { task in
            task.isAssigned(on: date)
        }
    }
    
    func completedTasksCount(for date: Date) -> Int {
        tasksForDate(date).filter { task in
            task.isCompleted(on: date)
        }.count
    }
    
    func totalTasksCount(for date: Date) -> Int {
        tasksForDate(date).count
    }
}

// MARK: - Week Day Cell Admin
struct WeekDayCellAdmin: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTasks: Bool
    let completedCount: Int
    let totalCount: Int
    let onTap: () -> Void
    
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                Text("\(dayNumber)")
                    .font(.system(size: 15, weight: isToday ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                // Indicador de tareas
                if hasTasks {
                    HStack(spacing: 1) {
                        Circle()
                            .fill(completedCount == totalCount ? Color.green : Color.orange)
                            .frame(width: 4, height: 4)
                    }
                } else {
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isToday && !isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    CalendarWidgetViewAdmin()
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
}
