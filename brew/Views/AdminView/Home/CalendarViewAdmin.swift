//
//  CalendarViewAdmin.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//  Dashboard - Calendario para administrador
//

import SwiftUI
import SwiftData

// MARK: - Technician Task Model (Read-only for Admin)
struct TechnicianTaskAdmin: Identifiable {
    let id = UUID()
    let technicianName: String
    let taskTitle: String
    let taskDescription: String
    let icon: String
    let colorHex: String
    let assignedDates: [Date]
    let completedDates: [Date]
    let parcelaId: String?
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    func isCompleted(on date: Date) -> Bool {
        completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func isAssigned(on date: Date) -> Bool {
        assignedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
}

// MARK: - Calendar View Admin
struct CalendarViewAdmin: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingMonthPicker = false
    @State private var tempSelectedDate = Date()
    
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
            // Header - Solo navegación, sin botones de edición
            HStack(alignment: .center, spacing: 16) {
                // Botón Back
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Botón Hoy
                Button(action: {
                    selectedDate = Date()
                    currentMonth = Date()
                }) {
                    Text("Hoy")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .frame(height: 44)
            
            Text("Tu Organización")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 4)
            
            Text("Supervisa las tareas y el calendario de tu equipo.")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 9)
            
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: { showingMonthPicker = true }) {
                    Text(monthYearString)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            CalendarGridViewAdmin(
                currentMonth: currentMonth,
                selectedDate: $selectedDate,
                tasks: technicianTasks
            )
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedDateString)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Tareas completadas: \(completedTasksCount)/\(totalTasksCount)")
                    .font(.subheadline)
                    .foregroundColor(completedTasksCount == totalTasksCount && totalTasksCount > 0 ? .green : .gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    let assignedTasks = tasksForSelectedDate
                    
                    if !assignedTasks.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(assignedTasks) { task in
                                TechnicianTaskRowAdmin(
                                    task: task,
                                    selectedDate: selectedDate
                                )
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No hay tareas programadas")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Los técnicos no tienen actividades para este día")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingMonthPicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "Selecciona fecha",
                        selection: $tempSelectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Ir a fecha")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") {
                            currentMonth = tempSelectedDate
                            selectedDate = tempSelectedDate
                            showingMonthPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
            .onAppear {
                tempSelectedDate = selectedDate
            }
        }
    }
    
    var tasksForSelectedDate: [TechnicianTaskAdmin] {
        technicianTasks.filter { task in
            task.isAssigned(on: selectedDate)
        }
    }
    
    var totalTasksCount: Int {
        tasksForSelectedDate.count
    }
    
    var completedTasksCount: Int {
        tasksForSelectedDate.filter { task in
            task.isCompleted(on: selectedDate)
        }.count
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: currentMonth).capitalized
    }
    
    var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: selectedDate)
    }
    
    func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

// MARK: - Calendar Grid View Admin
struct CalendarGridViewAdmin: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let tasks: [TechnicianTaskAdmin]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekDays = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCellAdmin(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            tasks: tasksForDate(date),
                            onTap: { selectedDate = date }
                        )
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
        }
    }
    
    var daysInMonth: [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = Calendar.current.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let range = Calendar.current.range(of: .day, in: .month, for: currentMonth)!
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func tasksForDate(_ date: Date) -> [TechnicianTaskAdmin] {
        tasks.filter { task in
            task.isAssigned(on: date)
        }
    }
}

// MARK: - Day Cell Admin
struct DayCellAdmin: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let tasks: [TechnicianTaskAdmin]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if !tasks.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(tasks.prefix(4).enumerated()), id: \.element.id) { index, task in
                            Circle()
                                .fill(task.color)
                                .frame(width: 5, height: 5)
                                .opacity(task.isCompleted(on: date) ? 1.0 : 0.4)
                        }
                    }
                    .frame(height: 6)
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Technician Task Row Admin (Read-only)
struct TechnicianTaskRowAdmin: View {
    let task: TechnicianTaskAdmin
    let selectedDate: Date
    
    @State private var showingDetails = false
    
    var isCompletedToday: Bool {
        task.isCompleted(on: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: task.icon)
                    .font(.title2)
                    .foregroundColor(task.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.technicianName)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Text(task.taskTitle)
                            .font(.subheadline)
                            .foregroundColor(task.color)
                        
                        if let parcelaId = task.parcelaId {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            
                            Text(parcelaId)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(isCompletedToday ? "Completada" : "Pendiente")
                            .font(.caption)
                            .foregroundColor(isCompletedToday ? .green : .orange)
                        
                        if !task.taskDescription.isEmpty {
                            Button(action: { showingDetails.toggle() }) {
                                Image(systemName: showingDetails ? "chevron.up.circle.fill" : "info.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Indicador de estado (solo lectura)
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isCompletedToday ? task.color.opacity(0.2) : Color.clear)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(task.color)
                            .opacity(isCompletedToday ? 1 : 0)
                    )
                    .frame(width: 28, height: 28)
            }
            
            if showingDetails && !task.taskDescription.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("Descripción:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(task.taskDescription)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .animation(.easeInOut(duration: 0.2), value: showingDetails)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        CalendarViewAdmin()
    }
}
