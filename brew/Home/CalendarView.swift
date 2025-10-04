//
//  CalendarView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 29/09/25.
//

import SwiftUI
import SwiftData

// MARK: - Activity Model with SwiftData
@Model
final class Activity {
    var id: UUID
    var title: String
    var activityDescription: String
    var icon: String
    var colorHex: String
    var assignedDates: [Date]
    var completedDates: [Date]
    
    init(id: UUID = UUID(), title: String, activityDescription: String = "", icon: String, colorHex: String, assignedDates: [Date] = [], completedDates: [Date] = []) {
        self.id = id
        self.title = title
        self.activityDescription = activityDescription
        self.icon = icon
        self.colorHex = colorHex
        self.assignedDates = assignedDates
        self.completedDates = completedDates
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Activity Validation
enum ActivityValidationError: LocalizedError {
    case emptyTitle
    case titleTooLong
    case descriptionTooLong
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "El nombre de la actividad no puede estar vacío"
        case .titleTooLong:
            return "El nombre no puede exceder 255 caracteres"
        case .descriptionTooLong:
            return "La descripción no puede exceder 500 caracteres"
        }
    }
}

struct ActivityValidator {
    static func validate(title: String, description: String) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ActivityValidationError.emptyTitle
        }
        
        guard title.count <= 255 else {
            throw ActivityValidationError.titleTooLong
        }
        
        guard description.count <= 500 else {
            throw ActivityValidationError.descriptionTooLong
        }
    }
    
    static func isValidTitle(_ title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && title.count <= 255
    }
}

// Note: Color extensions moved to ColorExtensions.swift

// MARK: - CalendarView Component
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var activities: [Activity]
    
    @State private var selectedDate = Date()
    @State private var showingAddActivity = false
    @State private var showingPresetActivities = false
    @State private var currentMonth = Date()
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingMonthPicker = false
    @State private var tempSelectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header personalizado - TODOS los elementos al mismo nivel
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
                
                // Botón de lista (verde)
                Button(action: { showingPresetActivities = true }) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                
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
                
                // Botón +
                Button(action: { showingAddActivity = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(height: 44)
            
            Text("Agenda")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
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
            
            CalendarGridView(
                currentMonth: currentMonth,
                selectedDate: $selectedDate,
                activities: activities
            )
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedDateString)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Actividades completadas: \(completedActivitiesCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    let assignedActivities = activities.filter { activity in
                        activity.assignedDates.contains { date in
                            Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        }
                    }
                    
                    if !assignedActivities.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(assignedActivities) { activity in
                                ActivityRow(
                                    activity: activity,
                                    selectedDate: selectedDate,
                                    onDelete: { deleteActivity(activity) },
                                    onToggle: { toggleCompletion(activity) },
                                    onUnassign: { unassignFromToday(activity) }
                                )
                            }
                        }
                    }
                    
                    let unassignedActivities = activities.filter { activity in
                        !activity.assignedDates.contains { date in
                            Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        }
                    }
                    
                    if !unassignedActivities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(assignedActivities.isEmpty ? "Tareas disponibles" : "Agregar más tareas")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, assignedActivities.isEmpty ? 0 : 8)
                            
                            ForEach(unassignedActivities) { activity in
                                UnassignedActivityRow(
                                    activity: activity,
                                    onAssign: { assignToToday(activity) }
                                )
                            }
                        }
                    }
                    
                    if activities.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No hay actividades")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Presiona el + arriba para crear una")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddActivity) {
            AddActivitySheet(
                modelContext: modelContext,
                onError: { error in
                    errorMessage = error
                    showingError = true
                }
            )
        }
        .sheet(isPresented: $showingPresetActivities) {
            PresetActivitiesSheet(
                modelContext: modelContext,
                activities: activities
            )
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Error desconocido")
        }
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
    
    var completedActivitiesCount: Int {
        activities.filter { activity in
            guard activity.assignedDates.contains(where: { date in
                Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }) else { return false }
            
            return activity.completedDates.contains { date in
                Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
        }.count
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: currentMonth)
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
    
    func deleteActivity(_ activity: Activity) {
        withAnimation {
            modelContext.delete(activity)
        }
    }
    
    func assignToToday(_ activity: Activity) {
        withAnimation(.spring(response: 0.3)) {
            if !activity.assignedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                activity.assignedDates.append(selectedDate)
            }
        }
    }
    
    func unassignFromToday(_ activity: Activity) {
        withAnimation {
            activity.assignedDates.removeAll { date in
                Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
            activity.completedDates.removeAll { date in
                Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
        }
    }
    
    func toggleCompletion(_ activity: Activity) {
        withAnimation {
            if let index = activity.completedDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                activity.completedDates.remove(at: index)
            } else {
                activity.completedDates.append(selectedDate)
            }
        }
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let activities: [Activity]
    
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
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            activities: activitiesForDate(date),
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
    
    func activitiesForDate(_ date: Date) -> [Activity] {
        activities.filter { activity in
            activity.assignedDates.contains { assignedDate in
                Calendar.current.isDate(assignedDate, inSameDayAs: date)
            }
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let activities: [Activity]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if !activities.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(activities.prefix(4).enumerated()), id: \.element.id) { index, activity in
                            Circle()
                                .fill(activity.color)
                                .frame(width: 5, height: 5)
                                .opacity(isActivityCompleted(activity) ? 1.0 : 0.4)
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
    
    func isActivityCompleted(_ activity: Activity) -> Bool {
        activity.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
}

// MARK: - Unassigned Activity Row
struct UnassignedActivityRow: View {
    let activity: Activity
    let onAssign: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: activity.icon)
                .font(.title3)
                .foregroundColor(activity.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if !activity.activityDescription.isEmpty {
                    Text(activity.activityDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button(action: onAssign) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray.opacity(0.3))
                )
        )
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: Activity
    let selectedDate: Date
    let onDelete: () -> Void
    let onToggle: () -> Void
    let onUnassign: () -> Void
    @State private var showingDetails = false
    @State private var showingEditSheet = false
    
    var isCompletedToday: Bool {
        activity.completedDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: activity.icon)
                    .font(.title2)
                    .foregroundColor(activity.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .strikethrough(isCompletedToday, color: .gray)
                    
                    HStack(spacing: 4) {
                        Text(isCompletedToday ? "Completada" : "Pendiente")
                            .font(.caption)
                            .foregroundColor(isCompletedToday ? .green : .orange)
                        
                        if !activity.activityDescription.isEmpty {
                            Button(action: { showingDetails.toggle() }) {
                                Image(systemName: showingDetails ? "chevron.up.circle.fill" : "info.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onToggle) {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(isCompletedToday ? activity.color.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(activity.color)
                                .opacity(isCompletedToday ? 1 : 0)
                        )
                        .frame(width: 28, height: 28)
                }
            }
            
            if showingDetails && !activity.activityDescription.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("Descripción:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(activity.activityDescription)
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
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("Editar", systemImage: "pencil")
            }
            
            Button(action: onUnassign) {
                Label("Quitar de este día", systemImage: "minus.circle")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Eliminar actividad", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditActivitySheet(activity: activity)
        }
    }
}

// MARK: - Preset Activities Sheet
struct PresetActivitiesSheet: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let activities: [Activity]
    
    let presetActivities = [
        ("Regar", "", "drop.fill", "007AFF"),
        ("Fertilizar", "Aplicar nutrientes a las plantas", "speedometer", "34C759"),
        ("Visita al Plot", "Inspección del terreno", "figure.walk", "FF9500"),
        ("Podar", "Revisar y cortar plantas", "eye.fill", "AF52DE"),
        ("Fotos de Progreso", "Documentar crecimiento", "photo.fill", "FF2D55"),
        ("Control de Plagas", "Revisar y tratar plagas", "ladybug.fill", "FF3B30"),
        ("Revisar Humedad", "Medir niveles de humedad", "humidity.fill", "32ADE6"),
        ("Exposición Solar", "Verificar luz solar", "sun.max.fill", "FFCC00"),
        ("Cosechar", "Recolectar frutos/plantas", "basket.fill", "8B4513"),
        ("Aplicar Compost", "Añadir compost al suelo", "speedometer", "996633"),
        ("Revisar Raíces", "Inspección de raíces", "eye.fill", "8B4513")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Selecciona tareas comunes para tu calendario de cuidado de plantas")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Section("Tareas Predefinidas") {
                    ForEach(presetActivities, id: \.0) { preset in
                        Button(action: {
                            addPresetActivity(title: preset.0, description: preset.1, icon: preset.2, colorHex: preset.3)
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: preset.2)
                                    .font(.title2)
                                    .foregroundColor(Color(hex: preset.3))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preset.0)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    if !preset.1.isEmpty {
                                        Text(preset.1)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                if activities.contains(where: { $0.title == preset.0 }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tareas Predefinidas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func addPresetActivity(title: String, description: String, icon: String, colorHex: String) {
        guard !activities.contains(where: { $0.title == title }) else { return }
        
        let newActivity = Activity(
            title: title,
            activityDescription: description,
            icon: icon,
            colorHex: colorHex
        )
        
        modelContext.insert(newActivity)
    }
}

// MARK: - Add Activity Sheet
struct AddActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let onError: (String) -> Void
    
    @State private var title = ""
    @State private var activityDescription = ""
    @State private var selectedIcon = "drop.fill"
    @State private var selectedColor = Color.blue
    
    let icons = ["drop.fill", "leaf.fill", "sun.max.fill", "humidity.fill", "photo.fill", "figure.walk", "eye.fill", "speedometer", "basket.fill", "ladybug.fill", "wind", "bolt.fill"]
    let colors: [Color] = [.blue, .pink, .purple, .orange, .green, .red, .yellow, .cyan]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Nombre") {
                    TextField("Nombre de la actividad", text: $title)
                    Text("\(title.count)/255")
                        .font(.caption)
                        .foregroundColor(title.count > 255 ? .red : .gray)
                }
                
                Section("Descripción (Opcional)") {
                    TextEditor(text: $activityDescription)
                        .frame(height: 80)
                    Text("\(activityDescription.count)/500")
                        .font(.caption)
                        .foregroundColor(activityDescription.count > 500 ? .red : .gray)
                }
                
                Section("Icono") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedIcon = icon
                                    }
                                }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 28))
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                        .frame(width: 60, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon ? selectedColor.opacity(0.1) : Color.clear)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedIcon == icon ? selectedColor : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedColor = color
                                    }
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 4)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(color, lineWidth: 2)
                                        )
                                        .shadow(color: selectedColor == color ? color.opacity(0.4) : .clear, radius: 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Nueva Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        addActivity()
                    }
                }
            }
        }
    }
    
    func addActivity() {
        do {
            try ActivityValidator.validate(title: title, description: activityDescription)
            
            let newActivity = Activity(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                activityDescription: activityDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                icon: selectedIcon,
                colorHex: selectedColor.toHex()
            )
            
            modelContext.insert(newActivity)
            dismiss()
        } catch {
            onError(error.localizedDescription)
        }
    }
}

// MARK: - Edit Activity Sheet
struct EditActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    let activity: Activity
    
    @State private var newTitle: String = ""
    @State private var newDescription: String = ""
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Nombre") {
                    TextField("Nombre de la actividad", text: $newTitle)
                    Text("\(newTitle.count)/255")
                        .font(.caption)
                        .foregroundColor(newTitle.count > 255 ? .red : .gray)
                }
                
                Section("Descripción") {
                    TextEditor(text: $newDescription)
                        .frame(height: 100)
                    Text("\(newDescription.count)/500")
                        .font(.caption)
                        .foregroundColor(newDescription.count > 500 ? .red : .gray)
                }
            }
            .navigationTitle("Editar Actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveChanges()
                    }
                    .disabled(newTitle.count > 255 || newDescription.count > 500)
                }
            }
            .onAppear {
                newTitle = activity.title
                newDescription = activity.activityDescription
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Error desconocido")
            }
        }
    }
    
    func saveChanges() {
        do {
            try ActivityValidator.validate(title: newTitle, description: newDescription)
            activity.title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            activity.activityDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Preview
#Preview {
    CalendarView()
        .modelContainer(for: Activity.self, inMemory: true)
}
