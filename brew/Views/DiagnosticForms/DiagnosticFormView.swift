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
    
    @Environment(\.dismiss) var dismiss
    @State private var parcelName = ""
    @State private var plantNumber = ""
    @State private var technicianName = ""
    @State private var totalPlants = ""
    @State private var additionalNotes = ""
    @State private var showValidationError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
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
                    Button(action: submitDiagnosis) {
                        HStack {
                            Spacer()
                            Text("Analizar Planta")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255))
                }
            }
            .navigationTitle("Información de Diagnóstico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Error de validación", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitDiagnosis() {
        guard validateForm() else { return }
        
        let request = PhotoAnalysisRequest(
            imageData: imageData,
            parcelName: parcelName,
            plantNumber: plantNumber,
            technicianName: technicianName,
            totalPlants: Int(totalPlants) ?? 0,
            additionalNotes: additionalNotes.isEmpty ? nil : additionalNotes
        )
        
        viewModel.analyzePhoto(request: request)
        onComplete()
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
