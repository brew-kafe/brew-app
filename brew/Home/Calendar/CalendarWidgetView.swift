//
//  CalendarWidgetView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 29/09/25.
//

import SwiftUI
import SwiftData

// MARK: - Task Summary Chip
struct TaskSummaryChip: View {
    let activity: Activity
    let selectedDate: Date
    
    var isCompleted: Bool {
        activity.completedDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: activity.icon)
                .font(.caption2)
                .foregroundColor(activity.color)
            
            Text(activity.title)
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
        .background(activity.color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(activity.color.opacity(0.25), lineWidth: 1)
        )
    }
}

struct CalendarWidgetView: View {
    @Query private var activities: [Activity]
    @State private var selectedDate = Date()
    
    let weekDays = ["D", "L", "M", "M", "J", "V", "S"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con título y botón para ver calendario completo
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mi Agenda")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(monthYearString)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: CalendarView()) {
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
                    WeekDayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        hasActivities: hasActivities(for: date),
                        completedCount: completedActivitiesCount(for: date),
                        totalCount: totalActivitiesCount(for: date),
                        onTap: { selectedDate = date }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Indicador de actividades del día seleccionado
            VStack(alignment: .leading, spacing: 8) {
                if totalActivitiesCount(for: selectedDate) > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("\(completedActivitiesCount(for: selectedDate)) de \(totalActivitiesCount(for: selectedDate)) completadas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Resumen de tareas del día
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(activitiesForDate(selectedDate).prefix(4)) { activity in
                                TaskSummaryChip(
                                    activity: activity,
                                    selectedDate: selectedDate
                                )
                            }
                            
                            if activitiesForDate(selectedDate).count > 4 {
                                Text("+\(activitiesForDate(selectedDate).count - 4)")
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
                        
                        Text("Sin tareas pendientes")
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
    
    func hasActivities(for date: Date) -> Bool {
        return !activitiesForDate(date).isEmpty
    }
    
    func activitiesForDate(_ date: Date) -> [Activity] {
        activities.filter { activity in
            activity.assignedDates.contains { assignedDate in
                Calendar.current.isDate(assignedDate, inSameDayAs: date)
            }
        }
    }
    
    func completedActivitiesCount(for date: Date) -> Int {
        activitiesForDate(date).filter { activity in
            activity.completedDates.contains { completedDate in
                Calendar.current.isDate(completedDate, inSameDayAs: date)
            }
        }.count
    }
    
    func totalActivitiesCount(for date: Date) -> Int {
        activitiesForDate(date).count
    }
}

// MARK: - Week Day Cell

struct WeekDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasActivities: Bool
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
                
                // Indicador de actividades
                if hasActivities {
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
    CalendarWidgetView()
        .modelContainer(for: Activity.self, inMemory: true)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
}
