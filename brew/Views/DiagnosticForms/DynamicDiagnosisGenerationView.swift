//
//  DynamicDiagnosisGenerationView.swift
//  brew
//
//  Created by AI Assistant on 14/10/25.
//

import SwiftUI

struct DynamicDiagnosisGenerationView: View {
    @StateObject private var diagnosisViewModel: DiagnosisViewModel
    @State private var isGenerating = false
    @State private var generationProgress: String = ""
    @State private var currentStep: GenerationStep = .analyzing
    @State private var showingResult = false
    @State private var animationProgress: Double = 0.0
    @State private var detailedProgress: String = ""
    @State private var completedTasks: [String] = []
    @State private var currentTask: String = ""
    @State private var showDetailedItinerary = false
    
    let capturedImage: UIImage?
    let onCompletion: (DiagnosisEntity) -> Void
    
    init(diagnosisViewModel: DiagnosisViewModel, capturedImage: UIImage? = nil, onCompletion: @escaping (DiagnosisEntity) -> Void) {
        self._diagnosisViewModel = StateObject(wrappedValue: diagnosisViewModel)
        self.capturedImage = capturedImage
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simple background
                Color(.systemBackground)
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if showingResult {
                        // Show diagnosis results after generation completes
                        diagnosisResultsView
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                    } else if !isGenerating {
                        readyStateView
                    } else {
                        dynamicGenerationView
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Ready State View
    
    private var readyStateView: some View {
        VStack(spacing: 25) {
            // Header with simple design
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                
                Text("Generación de Diagnóstico IA")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Genera un diagnóstico completo de la planta usando inteligencia artificial")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            }
            
            // Image preview (if available)
            if let image = capturedImage {
                imagePreviewCard(image: image)
            }
            
            Spacer()
            
            // Generation button
            generateButton
        }
        .onAppear {
            startIdleAnimation()
        }
    }
    
    // MARK: - Dynamic Generation View
    
    private var dynamicGenerationView: some View {
        VStack(spacing: 30) {
            // Dynamic header based on current step
            dynamicHeader
            
            // Step-by-step progress
            generationStepsView
            
            // Animated progress visualization
            progressVisualization
            
            // Dynamic content based on step
            stepSpecificContent
            
            // Detailed Itinerary Section
            if showDetailedItinerary {
                detailedItineraryView
            }
            
            Spacer()
        }
    }
    
    // MARK: - Components
    
    private var testModeIndicator: some View {
        HStack {
            Image(systemName: "flask.fill")
                .foregroundColor(.orange)
            Text("Test Mode Active")
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(20)
    }
    
    private func imagePreviewCard(image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sample Image")
                .font(.headline)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var generateButton: some View {
        Button(action: startGeneration) {
            HStack {
                Image(systemName: "brain.head.profile")
                Text("Iniciar Análisis IA")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var dynamicHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                // Rotating ring
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(animationProgress))
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: currentStep.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .scaleEffect(1.0 + sin(animationProgress * 4) * 0.1)
            }
            
            Text(currentStep.title)
                .font(.title2)
                .fontWeight(.bold)
                .animation(.easeInOut, value: currentStep)
            
            Text(generationProgress)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .animation(.easeInOut, value: generationProgress)
        }
    }
    
    private var generationStepsView: some View {
        HStack(spacing: 20) {
            ForEach(GenerationStep.allCases, id: \.self) { step in
                VStack(spacing: 8) {
                    Circle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: step == currentStep ? 2 : 0)
                                .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        )
                    
                    Text(step.shortTitle)
                        .font(.caption2)
                        .foregroundColor(step.rawValue <= currentStep.rawValue ? .primary : .secondary)
                }
                .animation(.spring(), value: currentStep)
                
                if step != GenerationStep.allCases.last {
                    Rectangle()
                        .fill(step.rawValue < currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .animation(.easeInOut, value: currentStep)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var progressVisualization: some View {
        VStack(spacing: 15) {
            // Floating particles animation
            ZStack {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(
                            x: cos(animationProgress * 2 + Double(index) * .pi / 3) * 40,
                            y: sin(animationProgress * 2 + Double(index) * .pi / 3) * 40
                        )
                        .scaleEffect(0.5 + sin(animationProgress * 3 + Double(index)) * 0.3)
                }
            }
            .frame(width: 100, height: 100)
            
            // Progress bar
            ProgressView(value: animationProgress)
                .tint(.blue)
                .scaleEffect(1.2)
        }
    }
    
    private var stepSpecificContent: some View {
        VStack(spacing: 15) {
            switch currentStep {
            case .analyzing:
                stepContent(
                    icon: "magnifyingglass",
                    title: "Analizando Imagen",
                    description: "Examinando características y síntomas de la planta"
                )
            case .identifying:
                stepContent(
                    icon: "leaf.fill",
                    title: "Identificando Problemas",
                    description: "Detectando posibles problemas de salud de la planta"
                )
            case .generating:
                stepContent(
                    icon: "brain.head.profile",
                    title: "Generando Diagnóstico",
                    description: "Creando diagnóstico completo y recomendaciones"
                )
            case .complete:
                stepContent(
                    icon: "checkmark.circle.fill",
                    title: "Análisis Completo",
                    description: "Listo para ver resultados detallados"
                )
            }
            
            // Current Task Display
            if !currentTask.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(.blue)
                            .scaleEffect(1.0 + sin(animationProgress * 4) * 0.1)
                        Text("Current Task")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    Text(currentTask)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 25)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Toggle for detailed view
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showDetailedItinerary.toggle()
                }
            }) {
                HStack {
                    Image(systemName: showDetailedItinerary ? "chevron.up" : "chevron.down")
                    Text(showDetailedItinerary ? "Hide Details" : "Show Details")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func stepContent(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .scaleEffect(1.0 + sin(animationProgress * 3) * 0.1)
            
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Detailed Itinerary View
    
    private var detailedItineraryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.blue)
                Text("Diagnosis Process Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Completed Tasks
            if !completedTasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completed:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    ForEach(completedTasks, id: \.self) { task in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(task)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Current Step Detailed Tasks
            VStack(alignment: .leading, spacing: 8) {
                Text("Paso Actual: \(currentStep.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                ForEach(currentStep.detailedTasks(), id: \.self) { task in
                    HStack(spacing: 8) {
                        Image(systemName: task == currentTask ? "gearshape.2.fill" : "circle")
                            .foregroundColor(task == currentTask ? .blue : .gray)
                            .font(.caption)
                            .scaleEffect(task == currentTask ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentTask)
                        
                        Text(task)
                            .font(.caption)
                            .foregroundColor(task == currentTask ? .primary : .secondary)
                            .fontWeight(task == currentTask ? .medium : .regular)
                        
                        Spacer()
                        
                        if completedTasks.contains(task) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
            
            // Upcoming Steps Preview
            let upcomingSteps = GenerationStep.allCases.filter { $0.rawValue > currentStep.rawValue }
            if !upcomingSteps.isEmpty && currentStep != .complete {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Coming Next:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    ForEach(upcomingSteps.prefix(2), id: \.self) { step in
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(step.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColors: [Color] {
        switch currentStep {
        case .analyzing:
            return [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)]
        case .identifying:
            return [Color.green.opacity(0.1), Color.mint.opacity(0.1)]
        case .generating:
            return [Color.purple.opacity(0.1), Color.pink.opacity(0.1)]
        case .complete:
            return [Color.green.opacity(0.2), Color.blue.opacity(0.1)]
        }
    }
    
    // MARK: - Diagnosis Results View
    
    private var diagnosisResultsView: some View {
        VStack(spacing: 20) {
            // Success indicator
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: currentStep)
                
                Text("Diagnosis Complete!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Diagnosis summary
            if let diagnosis = diagnosisViewModel.diagnoses.first {
                VStack(spacing: 16) {
                    DiagnosisResultCard(diagnosis: diagnosis)
                    
                    // Quick insights
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(detectionStateColor(diagnosis.detectionState))
                            Text("Health Status: \(diagnosis.detectionState.capitalized)")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Primary Issue: \(diagnosis.primaryDeficiency)")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        if let confidence = diagnosis.aiConfidence {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.blue)
                                Text("AI Confidence: \(Int(confidence * 100))%")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                    )
                }
            }
            
            Button(action: {
                handleViewDetailsAction()
            }) {
                Text("View Full Details")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .disabled(diagnosisViewModel.diagnoses.isEmpty)
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    private func detectionStateColor(_ state: String) -> Color {
        switch state.lowercased() {
        case "optimal": return .green
        case "moderate": return .orange
        case "danger": return .red
        default: return .gray
        }
    }
    
    // MARK: - Methods
    
    private func startIdleAnimation() {
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            animationProgress = 1.0
        }
    }
    
    private func startGeneration() {
        isGenerating = true
        animationProgress = 0.0
        currentStep = .analyzing
        
        // Start step progression
        progressThroughSteps()
    }
    
    private func progressThroughSteps() {
        let stepDuration: Double = 3.0
        let steps = GenerationStep.allCases
        
        for (index, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * stepDuration) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = step
                    animationProgress = Double(index + 1) / Double(steps.count)
                    generationProgress = step.progressMessage()
                }
                
                // Start detailed task progression for this step
                progressThroughDetailedTasks(for: step)
                
                // Complete generation on last step
                if step == .complete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        completeGeneration()
                    }
                }
            }
        }
    }
    
    private func progressThroughDetailedTasks(for step: GenerationStep) {
        let tasks = step.detailedTasks()
        let taskDuration: Double = 0.5
        
        for (taskIndex, task) in tasks.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(taskIndex) * taskDuration) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentTask = task
                }
                
                // Mark previous task as completed
                if taskIndex > 0 {
                    let previousTask = tasks[taskIndex - 1]
                    if !completedTasks.contains(previousTask) {
                        completedTasks.append(previousTask)
                    }
                }
                
                // Mark last task as completed when step finishes
                if taskIndex == tasks.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + taskDuration) {
                        if !completedTasks.contains(task) {
                            completedTasks.append(task)
                        }
                        currentTask = ""
                    }
                }
            }
        }
    }
    
    private func completeGeneration() {
        guard !showingResult else { return } // Prevent multiple calls
        
        // TODO: Integrate with real AI diagnosis service
        // For now, use mock diagnosis generation
        diagnosisViewModel.createTestDiagnosis {
            DispatchQueue.main.async {
                showingResult = true
            }
        }
    }
    
    // MARK: - Generation Steps
    
    enum GenerationStep: Int, CaseIterable {
        case analyzing = 0
        case identifying = 1
        case generating = 2
        case complete = 3
        
        var title: String {
            switch self {
            case .analyzing: return "Analizando Muestra"
            case .identifying: return "Identificando Problemas"
            case .generating: return "Generando Diagnóstico"
            case .complete: return "Análisis Completo"
            }
        }
        
        var shortTitle: String {
            switch self {
            case .analyzing: return "Analizar"
            case .identifying: return "Identificar"
            case .generating: return "Generar"
            case .complete: return "Completar"
            }
        }
        
        var icon: String {
            switch self {
            case .analyzing: return "magnifyingglass.circle.fill"
            case .identifying: return "leaf.fill"
            case .generating: return "brain.head.profile"
            case .complete: return "checkmark.circle.fill"
            }
        }
        
        func progressMessage() -> String {
            switch self {
            case .analyzing: return "Examinando características de la planta..."
            case .identifying: return "Detectando posibles problemas de salud..."
            case .generating: return "Creando análisis completo..."
            case .complete: return "¡Diagnóstico completado!"
            }
        }
        
        func detailedTasks() -> [String] {
            switch self {
            case .analyzing:
                return [
                    "Procesando imágenes capturadas",
                    "Extrayendo características de la planta",
                    "Analizando patrones de color",
                    "Midiendo características de las hojas",
                    "Evaluando estructura general"
                ]
            case .identifying:
                return [
                    "Ejecutando algoritmos de detección de enfermedades",
                    "Analizando deficiencias nutricionales",
                    "Verificando indicadores de plagas",
                    "Evaluando patrones de crecimiento",
                    "Consultando base de datos de plantas"
                ]
            case .generating:
                return [
                    "Compilando resultados del diagnóstico",
                    "Generando recomendaciones de tratamiento",
                    "Creando plan de acción",
                    "Formateando reporte completo",
                    "Validando resultados finales"
                ]
            case .complete:
                return [
                    "Reporte de diagnóstico listo",
                    "Recomendaciones compiladas",
                    "Plan de acción preparado"
                ]
            }
        }
    }
    
    // MARK: - Diagnosis Result Card
    
    private struct DiagnosisResultCard: View {
        let diagnosis: DiagnosisEntity
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(diagnosis.parcelName)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let plantNumber = diagnosis.plantNumber {
                            Text("Planta: \(plantNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(diagnosis.detectionState.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(detectionStateColor(diagnosis.detectionState).opacity(0.2))
                            )
                            .foregroundColor(detectionStateColor(diagnosis.detectionState))
                        
                        Text(formatDate(diagnosis.diagnosisDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let description = diagnosis.aiDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        
        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        private func detectionStateColor(_ state: String) -> Color {
            switch state.lowercased() {
            case "optimal": return .green
            case "moderate": return .orange
            case "danger": return .red
            default: return .gray
            }
        }
    }
    
    // MARK: - Preview
    
    struct DynamicDiagnosisGenerationView_Previews: PreviewProvider {
        static var previews: some View {
            DynamicDiagnosisGenerationView(
                diagnosisViewModel: DiagnosisViewModel(),
                capturedImage: nil
            ) { _ in
                // Preview completion handler
            }
        }
    }
    
    private func handleViewDetailsAction() {
        guard let diagnosis = diagnosisViewModel.diagnoses.first else {
            print("⚠️ No diagnosis available to display")
            return
        }
        
        // Ensure we're on main thread for UI updates
        DispatchQueue.main.async {
            onCompletion(diagnosis)
        }
    }
}
