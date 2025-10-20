//
//  DiagnosticFormView.swift
//  brew
//
//  Created by toño on 05/10/25.
//

import SwiftUI

struct DiagnosticFormView: View {
    let imageData: Data
    @ObservedObject var viewModel: DiagnosisViewModel
    let onComplete: () -> Void
    
    public init(imageData: Data, viewModel: DiagnosisViewModel, onComplete: @escaping () -> Void, dismiss: DismissAction? = nil, foundationModelsService: FoundationModelsDiagnosisService? = nil) {
        self.imageData = imageData
        self.viewModel = viewModel
        self.onComplete = onComplete
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var parcelName = ""
    @State private var plantNumber = ""
    @State private var technicianName = ""
    @State private var totalPlants = ""
    @State private var additionalNotes = ""
    @State private var showValidationError = false
    @State private var errorMessage = ""
    @State private var showingAIDiagnosis = false
    @State private var photoAnalysisResults: [ClassificationResult] = []
    
    private var foundationModelsService: FoundationModelsDiagnosisService? = {
        if #available(iOS 18.1, macOS 15.1, *) {
            return FoundationModelsDiagnosisService.shared
        } else {
            return nil
        }
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                        } else {
                            Text("⚠️ Error: No se pudo cargar la imagen")
                                .foregroundColor(.red)
                        }
                    } header: {
                        Text("Foto capturada")
                    }
                    
                    Section {
                        TextField("Nombre de la parcela", text: $parcelName)
                        
                        TextField("Número de planta", text: $plantNumber)
                        
                        TextField("Nombre del técnico", text: $technicianName)
                        
                        TextField("Total de plantas en muestra", text: $totalPlants)
                            .keyboardType(.numberPad)
                    } header: {
                        Text("Información del diagnóstico")
                    } footer: {
                        Text("Completa todos los campos requeridos para continuar con el análisis.")
                    }
                    
                    Section {
                        TextEditor(text: $additionalNotes)
                            .frame(minHeight: 100)
                    } header: {
                        Text("Notas adicionales (opcional)")
                    }
                    
                    Section {
                        // AI Diagnosis Generation Button
                        if #available(iOS 18.1, macOS 15.1, *),
                           let service = foundationModelsService,
                           service.isModelAvailable {
                            Button(action: generateAIDiagnosis) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.white)
                                    Text("Generar diagnóstico")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.brown.opacity(0.8), Color.brown],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                            }
                            .disabled(viewModel.isAnalyzing || !isFormValid)
                        } else if #available(iOS 18.1, macOS 15.1, *),
                                  let service = foundationModelsService {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Apple Intelligence Required")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                                
                                Text(service.availabilityMessage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("AI Diagnosis")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Requires iOS 18.1 or later with Apple Intelligence")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .disabled(viewModel.isAnalyzing)
                
                // Analyzing overlay
                if viewModel.isAnalyzing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Analizando con Core ML...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Esto puede tomar unos segundos")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255))
                    )
                }
            }
            .navigationTitle("Información de Diagnóstico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(viewModel.isAnalyzing)
                }
            }
            .alert("Error de validación", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .onChange(of: viewModel.isAnalyzing) { oldValue, newValue in
                // When analysis completes, close the form
                if oldValue && !newValue && viewModel.errorMessage == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingAIDiagnosis) {
                if #available(iOS 18.1, macOS 15.1, *),
                   let uiImage = UIImage(data: imageData) {
                    DiagnosisGenerationView(
                        photoAnalysis: photoAnalysisResults,
                        capturedImage: uiImage,
                        parcelName: parcelName,
                        technicianName: technicianName,
                        additionalNotes: additionalNotes
                    )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !parcelName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !plantNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !technicianName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !totalPlants.isEmpty && Int(totalPlants) != nil && Int(totalPlants)! > 0
    }
    
    // MARK: - Methods
    
    private func generateAIDiagnosis() {
        guard validateForm() else {
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            errorMessage = "No se pudo procesar la imagen"
            showValidationError = true
            return
        }
        
        // First analyze the photo with CoreML, then use results for AI diagnosis
        viewModel.isAnalyzing = true
        
        PlantDiagnosticService.shared.classifyImage(image) { result in
            DispatchQueue.main.async {
                viewModel.isAnalyzing = false
                
                switch result {
                case .success(let classifications):
                    photoAnalysisResults = classifications
                    showingAIDiagnosis = true
                    
                case .failure(let error):
                    errorMessage = "Error en análisis de imagen: \(error.localizedDescription)"
                    showValidationError = true
                }
            }
        }
    }
    
    private func submitDiagnosis() {
        print("🔍 Submit diagnosis tapped")
        
        guard validateForm() else {
            print("❌ Form validation failed")
            return
        }
        
        print("✅ Form validated successfully")
        print("📦 Creating analysis request...")
        
        let request = PhotoAnalysisRequest(
            imageData: imageData,
            parcelName: parcelName,
            plantNumber: plantNumber,
            technicianName: technicianName,
            totalPlants: Int(totalPlants) ?? 0,
            additionalNotes: additionalNotes.isEmpty ? nil : additionalNotes
        )
        
        print("🚀 Starting ML analysis...")
        print("   - Parcel: \(parcelName)")
        print("   - Plant: \(plantNumber)")
        print("   - Total plants: \(totalPlants)")
        print("   - Image size: \(imageData.count) bytes")
        
        viewModel.analyzePhoto(request: request)
    }
    
    private func validateForm() -> Bool {
        if parcelName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa el nombre de la parcela"
            showValidationError = true
            return false
        }
        
        if plantNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa el número de planta"
            showValidationError = true
            return false
        }
        
        if technicianName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Por favor ingresa el nombre del técnico"
            showValidationError = true
            return false
        }
        
        if totalPlants.isEmpty || Int(totalPlants) == nil || Int(totalPlants)! <= 0 {
            errorMessage = "Por favor ingresa un número válido de plantas"
            showValidationError = true
            return false
        }
        
        return true
    }
}

#Preview {
    DiagnosticFormView(
        imageData: Data(),
        viewModel: DiagnosisViewModel(),
        onComplete: {}
    )
}
