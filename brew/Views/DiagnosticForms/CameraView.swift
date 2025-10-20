//
//  CameraView.swift
//  brew
//
//  Created by: toño
//

import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - Main Camera View
struct CameraView: View {
    @StateObject var camera = CameraModel()
    @ObservedObject var diagnosisViewModel: DiagnosisViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showDiagnosisGeneration = false
    @State private var selectedDiagnosis: DiagnosisEntity?
    @State private var photoAnalysisResults: [ClassificationResult] = []
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isAnalyzing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showAvailabilityError = false
    @State private var availabilityMessage = ""
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // MARK: - Main Image Area
            VStack {
                Spacer(minLength: 90)
                
                ZStack {
                    if camera.isTaken, let uiImage = UIImage(data: camera.picData) {
                        // Show captured or selected image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 340, height: 450)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 88/255, green: 92/255, blue: 48/255), lineWidth: 10)
                            )
                    } else {
                        // Live camera preview
                        CameraPreview(camera: camera)
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 340, height: 450)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 88/255, green: 92/255, blue: 48/255), lineWidth: 10)
                            )
                    }
                }
                
                Spacer().frame(height: 25)
            }
            
            // MARK: - Top Controls
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    if camera.isTaken {
                        Button(action: camera.reTake) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
            }
            
            // MARK: - Processing Overlay
            if camera.isProcessing || isAnalyzing {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView().scaleEffect(1.5).tint(.white)
                    Text(isAnalyzing ? "Analizando con CoreML..." : "Procesando foto...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        // MARK: - Bottom Toolbar (Refactored)
        .safeAreaInset(edge: .bottom) {
            BottomToolbarView(
                camera: camera,
                selectedItem: $selectedItem,
                isAnalyzing: $isAnalyzing,
                onAnalyze: analyzePhotoAndGenerate
            )
        }
        // MARK: - Handle Library Image Selection
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    camera.picData = data
                    camera.isTaken = true
                }
            }
        }
        // MARK: - Diagnosis Generation Screen
        .fullScreenCover(isPresented: $showDiagnosisGeneration) {
            if #available(iOS 18.1, macOS 15.1, *),
               let uiImage = UIImage(data: camera.picData) {
                DiagnosisGenerationView(
                    photoAnalysis: photoAnalysisResults,
                    capturedImage: uiImage,
                    parcelName: "Parcela desde cámara",
                    technicianName: "Técnico",
                    additionalNotes: "",
                    diagnosisViewModel: diagnosisViewModel
                )
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Requiere iOS 18.1+")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Apple Intelligence debe estar habilitado")
                        .foregroundColor(.secondary)
                    Button("Cerrar") {
                        showDiagnosisGeneration = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        // MARK: - Diagnosis Detail
        .sheet(item: $selectedDiagnosis) { diagnosis in
            DiagnosticDetailView(diagnosis: diagnosis, viewModel: diagnosisViewModel)
        }
        // MARK: - Error Alert
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        // MARK: - Availability Error Alert
        .alert("Apple Intelligence No Disponible", isPresented: $showAvailabilityError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(availabilityMessage)
        }
    }

    // MARK: - Methods
    private func analyzePhotoAndGenerate() {
        guard let image = UIImage(data: camera.picData) else {
            errorMessage = "No se pudo cargar la imagen"
            showError = true
            return
        }

        // Check Foundation Models availability before proceeding
        if #available(iOS 18.1, macOS 15.1, *) {
            let foundationService = FoundationModelsDiagnosisService.shared

            if !foundationService.isModelAvailable {
                availabilityMessage = foundationService.availabilityMessage
                showAvailabilityError = true
                return
            }
        } else {
            availabilityMessage = "Requiere iOS 18.1 o superior para usar Apple Intelligence"
            showAvailabilityError = true
            return
        }

        isAnalyzing = true

        PlantDiagnosticService.shared.classifyImage(image) { result in
            DispatchQueue.main.async {
                isAnalyzing = false

                switch result {
                case .success(let classifications):
                    photoAnalysisResults = classifications
                    showDiagnosisGeneration = true
                case .failure(let error):
                    errorMessage = "Error en análisis: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Bottom Toolbar View (Refactored)
struct BottomToolbarView: View {
    @ObservedObject var camera: CameraModel
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var isAnalyzing: Bool
    var onAnalyze: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            if camera.isTaken {
                Button(action: {
                    if camera.picData.count > 0 {
                        onAnalyze()
                    } else {
                        camera.reTake()
                    }
                }) {
                    Text("Generar Diagnóstico IA")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 32)
                        .background(
                            Capsule().fill(Color(red: 88/255, green: 92/255, blue: 48/255))
                        )
                }
                .disabled(camera.picData.isEmpty || isAnalyzing)
                .opacity(camera.picData.isEmpty || isAnalyzing ? 0.5 : 1.0)
            } else {
                Button(action: camera.takePic) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(32)
                        .background(
                            Circle().fill(Color(red: 88/255, green: 92/255, blue: 48/255))
                        )
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(32)
                        .background(
                            Circle().fill(Color(red: 88/255, green: 92/255, blue: 48/255))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 55)
    }
}

// MARK: - Preview
#Preview {
    CameraView(diagnosisViewModel: DiagnosisViewModel())
}
