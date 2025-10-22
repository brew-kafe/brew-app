//
//  DiagnosisViewModel.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI

@MainActor
class DiagnosisViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var currentDiagnosis: DiagnosisEntity?
    @Published var diagnosesList: [DiagnosisEntity] = []
    @Published var processingStep: String = ""
    
    // MARK: - Services
    private let coordinator = DiagnosisCoordinator.shared
    private let apiService = APIDiagnosisService.shared
    private let coreMLService = PlantDiagnosticService.shared
    
    // MARK: - User Data
    var userId: String = "default_user_id" // Should come from authentication
    var technicianName: String = "Técnico" // Should come from user profile
    
    // MARK: - Image Selection
    func loadImage() async {
        guard let photoItem = selectedPhotoItem else { return }
        
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            errorMessage = "Error al cargar imagen: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Complete Diagnosis Workflow
    /// Example 1: Complete workflow (API → Local Storage)
    func performCompleteDiagnosis(
        parcelName: String,
        plantNumber: String?,
        modelContext: ModelContext
    ) async {
        guard let image = selectedImage else {
            errorMessage = "No hay imagen seleccionada"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let diagnosis = try await coordinator.performCompleteDiagnosis(
                image: image,
                userId: userId,
                parcelName: parcelName,
                plantNumber: plantNumber,
                technicianName: technicianName,
                modelContext: modelContext
            )
            
            currentDiagnosis = diagnosis
            successMessage = "Diagnóstico completado exitosamente"
            
            // Refresh list
            await fetchDiagnoses(modelContext: modelContext)
            
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - API Only Analysis
    /// Example 2: API analysis only (for quick checks)
    func analyzeWithAPI(
        parcelName: String,
        plantNumber: String?
    ) async -> PhotoAnalysisResponse? {
        guard let image = selectedImage else {
            errorMessage = "No hay imagen seleccionada"
            return nil
        }
        
        isProcessing = true
        processingStep = "Analizando con IA..."
        
        do {
            let result = try await coordinator.performAPIAnalysis(
                image: image,
                parcelName: parcelName,
                plantNumber: plantNumber,
                technicianName: technicianName
            )
            
            processingStep = "Análisis completado"
            return result
            
        } catch {
            errorMessage = "Error en análisis: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - CoreML Only Analysis
    /// Example 3: Local CoreML analysis only (offline mode)
    func analyzeLocally() async -> [ClassificationResult]? {
        guard let image = selectedImage else {
            errorMessage = "No hay imagen seleccionada"
            return nil
        }
        
        isProcessing = true
        processingStep = "Analizando localmente..."
        
        do {
            let results = try await coordinator.performLocalAnalysis(image: image)
            processingStep = "Análisis local completado"
            return results
            
        } catch {
            errorMessage = "Error en análisis local: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Fetch Operations
    /// Fetch diagnoses from local database
    func fetchDiagnoses(modelContext: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<DiagnosisEntity>(
                sortBy: [SortDescriptor(\.diagnosisDate, order: .reverse)]
            )
            diagnosesList = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error al cargar diagnósticos: \(error.localizedDescription)"
        }
    }
    
    /// Sync diagnoses from API
    func syncDiagnosesFromAPI(modelContext: ModelContext) async {
        isProcessing = true
        processingStep = "Sincronizando..."
        
        do {
            let synced = try await coordinator.syncDiagnoses(
                userId: userId,
                modelContext: modelContext
            )
            
            diagnosesList = synced
            successMessage = "Sincronizado: \(synced.count) diagnósticos"
            
        } catch {
            errorMessage = "Error en sincronización: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    /// Fetch single diagnosis from API
    func fetchDiagnosisFromAPI(diagnosisId: String) async -> DiagnosisAPIResponse? {
        do {
            return try await apiService.fetchDiagnosis(userId: userId, diagnosisId: diagnosisId)
        } catch {
            errorMessage = "Error al obtener diagnóstico: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Delete Operations
    func deleteDiagnosis(
        diagnosisId: String,
        entity: DiagnosisEntity,
        modelContext: ModelContext
    ) async {
        isProcessing = true
        
        do {
            try await coordinator.deleteDiagnosis(
                userId: userId,
                diagnosisId: diagnosisId,
                entity: entity,
                modelContext: modelContext
            )
            
            successMessage = "Diagnóstico eliminado"
            await fetchDiagnoses(modelContext: modelContext)
            
        } catch {
            errorMessage = "Error al eliminar: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - Utility Methods
    func fetchDetectionStates() async {
        do {
            let states = try await coordinator.fetchDetectionStates()
            print("Estados disponibles: \(states.states.keys)")
        } catch {
            errorMessage = "Error al obtener estados: \(error.localizedDescription)"
        }
    }
    
    func fetchSupportedElements() async {
        do {
            let elements = try await coordinator.fetchSupportedElements()
            print("Elementos soportados: \(elements.elements)")
        } catch {
            errorMessage = "Error al obtener elementos: \(error.localizedDescription)"
        }
    }
}

// MARK: - Example SwiftUI View
struct DiagnosisExampleView: View {
    @StateObject private var viewModel = DiagnosisViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @State private var parcelName = ""
    @State private var plantNumber = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Imagen") {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotoItem,
                        matching: .images
                    ) {
                        Label("Seleccionar Foto", systemImage: "photo")
                    }
                    .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                        Task {
                            await viewModel.loadImage()
                        }
                    }
                    
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                }
                
                Section("Información") {
                    TextField("Nombre de Parcela", text: $parcelName)
                    TextField("Número de Planta (opcional)", text: $plantNumber)
                }
                
                Section("Acciones") {
                    // Complete workflow
                    Button("Diagnóstico Completo (API + Local)") {
                        Task {
                            await viewModel.performCompleteDiagnosis(
                                parcelName: parcelName,
                                plantNumber: plantNumber.isEmpty ? nil : plantNumber,
                                modelContext: modelContext
                            )
                        }
                    }
                    .disabled(viewModel.isProcessing || parcelName.isEmpty)
                    
                    // API only
                    Button("Solo Análisis API") {
                        Task {
                            _ = await viewModel.analyzeWithAPI(
                                parcelName: parcelName,
                                plantNumber: plantNumber.isEmpty ? nil : plantNumber
                            )
                        }
                    }
                    .disabled(viewModel.isProcessing || parcelName.isEmpty)
                    
                    // CoreML only
                    Button("Solo Análisis Local") {
                        Task {
                            _ = await viewModel.analyzeLocally()
                        }
                    }
                    .disabled(viewModel.isProcessing)
                }
                
                Section("Estado") {
                    if viewModel.isProcessing {
                        HStack {
                            ProgressView()
                            Text(viewModel.processingStep)
                        }
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    
                    if let success = viewModel.successMessage {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }
                
                Section("Diagnósticos Guardados") {
                    Button("Sincronizar con API") {
                        Task {
                            await viewModel.syncDiagnosesFromAPI(modelContext: modelContext)
                        }
                    }
                    
                    ForEach(viewModel.diagnosesList) { diagnosis in
                        VStack(alignment: .leading) {
                            Text(diagnosis.primaryDeficiency)
                                .font(.headline)
                            Text(diagnosis.parcelName)
                                .font(.caption)
                            Text(diagnosis.diagnosisDate, style: .date)
                                .font(.caption2)
                        }
                    }
                }
            }
            .navigationTitle("Diagnóstico de Plantas")
            .task {
                await viewModel.fetchDiagnoses(modelContext: modelContext)
            }
        }
    }
}
