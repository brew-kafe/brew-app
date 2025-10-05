//
//  CalendarDataManager.swift
//  brew
//
//  Created by Monserrath Valenzuela on 29/09/25.
//

import Foundation
import SwiftData

// MARK: - Activity Data Manager (CRUD Operations)
class CalendarDataManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CREATE
    
    /// Crea una nueva actividad y la guarda en SwiftData
    func createActivity(
        title: String,
        description: String,
        icon: String,
        colorHex: String
    ) throws -> Activity {
        // Validar datos antes de crear
        try ActivityValidator.validate(title: title, description: description)
        
        // Crear la actividad
        let activity = Activity(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            activityDescription: description.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: icon,
            colorHex: colorHex
        )
        
        // Insertar en el contexto
        modelContext.insert(activity)
        
        // Guardar cambios
        try modelContext.save()
        
        return activity
    }
    
    /// Crea una actividad predefinida
    func createPresetActivity(
        title: String,
        description: String,
        icon: String,
        colorHex: String
    ) throws -> Activity {
        return try createActivity(
            title: title,
            description: description,
            icon: icon,
            colorHex: colorHex
        )
    }
    
    // MARK: - READ
    
    /// Obtiene todas las actividades
    func fetchAllActivities() throws -> [Activity] {
        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Obtiene actividades asignadas a una fecha específica
    func fetchActivities(for date: Date) throws -> [Activity] {
        let allActivities = try fetchAllActivities()
        
        return allActivities.filter { activity in
            activity.assignedDates.contains { assignedDate in
                Calendar.current.isDate(assignedDate, inSameDayAs: date)
            }
        }
    }
    
    /// Obtiene actividades completadas en una fecha específica
    func fetchCompletedActivities(for date: Date) throws -> [Activity] {
        let allActivities = try fetchAllActivities()
        
        return allActivities.filter { activity in
            activity.completedDates.contains { completedDate in
                Calendar.current.isDate(completedDate, inSameDayAs: date)
            }
        }
    }
    
    /// Busca una actividad por su ID
    func fetchActivity(byId id: UUID) throws -> Activity? {
        let descriptor = FetchDescriptor<Activity>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    // MARK: - UPDATE
    
    /// Actualiza el título de una actividad
    func updateTitle(for activity: Activity, newTitle: String) throws {
        try ActivityValidator.validate(title: newTitle, description: activity.activityDescription)
        activity.title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        try modelContext.save()
    }
    
    /// Actualiza la descripción de una actividad
    func updateDescription(for activity: Activity, newDescription: String) throws {
        try ActivityValidator.validate(title: activity.title, description: newDescription)
        activity.activityDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        try modelContext.save()
    }
    
    /// Asigna una actividad a una fecha
    func assignActivity(_ activity: Activity, to date: Date) throws {
        // Verificar si ya está asignada a esta fecha
        let alreadyAssigned = activity.assignedDates.contains { assignedDate in
            Calendar.current.isDate(assignedDate, inSameDayAs: date)
        }
        
        if !alreadyAssigned {
            activity.assignedDates.append(date)
            try modelContext.save()
        }
    }
    
    /// Desasigna una actividad de una fecha
    func unassignActivity(_ activity: Activity, from date: Date) throws {
        activity.assignedDates.removeAll { assignedDate in
            Calendar.current.isDate(assignedDate, inSameDayAs: date)
        }
        
        // También eliminar de completadas si estaba
        activity.completedDates.removeAll { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
        
        try modelContext.save()
    }
    
    /// Marca una actividad como completada en una fecha
    func completeActivity(_ activity: Activity, on date: Date) throws {
        // Verificar si ya está completada
        let alreadyCompleted = activity.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
        
        if !alreadyCompleted {
            activity.completedDates.append(date)
            try modelContext.save()
        }
    }
    
    /// Desmarca una actividad como completada en una fecha
    func uncompleteActivity(_ activity: Activity, on date: Date) throws {
        if let index = activity.completedDates.firstIndex(where: { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }) {
            activity.completedDates.remove(at: index)
            try modelContext.save()
        }
    }
    
    /// Alterna el estado de completado de una actividad
    func toggleCompletion(_ activity: Activity, on date: Date) throws {
        if let index = activity.completedDates.firstIndex(where: { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }) {
            activity.completedDates.remove(at: index)
        } else {
            activity.completedDates.append(date)
        }
        try modelContext.save()
    }
    
    // MARK: - DELETE
    
    /// Elimina una actividad
    func deleteActivity(_ activity: Activity) throws {
        modelContext.delete(activity)
        try modelContext.save()
    }
    
    /// Elimina todas las actividades (usar con precaución)
    func deleteAllActivities() throws {
        let allActivities = try fetchAllActivities()
        for activity in allActivities {
            modelContext.delete(activity)
        }
        try modelContext.save()
    }
    
    // MARK: - Helper Methods
    
    /// Verifica si una actividad está asignada a una fecha
    func isActivityAssigned(_ activity: Activity, to date: Date) -> Bool {
        return activity.assignedDates.contains { assignedDate in
            Calendar.current.isDate(assignedDate, inSameDayAs: date)
        }
    }
    
    /// Verifica si una actividad está completada en una fecha
    func isActivityCompleted(_ activity: Activity, on date: Date) -> Bool {
        return activity.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    /// Cuenta actividades completadas en una fecha
    func countCompletedActivities(on date: Date) throws -> Int {
        return try fetchCompletedActivities(for: date).count
    }
}
