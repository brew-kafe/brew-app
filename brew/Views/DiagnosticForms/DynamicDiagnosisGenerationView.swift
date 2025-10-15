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
                // Dynamic background
                LinearGradient(
                    gradient: Gradient(colors: backgroundColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: currentStep)
                
                VStack(spacing: 30) {
                    if !isGenerating {
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
            // Test Mode Indicator
            if diagnosisViewModel.isTestMode {
                testModeIndicator
            }
            
            // Header with dynamic animation
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.3), .green.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: diagnosisViewModel.isTestMode ? "flask.fill" : "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(diagnosisViewModel.isTestMode ? .orange : .blue)
                }
                
                Text(diagnosisViewModel.isTestMode ? "Test Mode Generation" : "AI Diagnosis Generation")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(diagnosisViewModel.isTestMode ? 
                     "Generate instant test diagnosis with mock data" : 
                     "Generate comprehensive plant diagnosis using AI")
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
                Image(systemName: diagnosisViewModel.isTestMode ? "wand.and.stars" : "sparkles")
                Text(diagnosisViewModel.isTestMode ? "Generate Test Diagnosis" : "Start AI Analysis")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: diagnosisViewModel.isTestMode ? 
                                     [.orange, .yellow] : [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .scaleEffect(1.0 + sin(animationProgress) * 0.02)
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
                    title: "Analyzing Image",
                    description: diagnosisViewModel.isTestMode ? 
                        "Processing test data..." : "Examining plant characteristics and symptoms"
                )
            case .identifying:
                stepContent(
                    icon: "leaf.fill",
                    title: "Identifying Issues",
                    description: diagnosisViewModel.isTestMode ? 
                        "Generating mock deficiencies..." : "Detecting potential plant health issues"
                )
            case .generating:
                stepContent(
                    icon: "brain.head.profile",
                    title: "Generating Diagnosis",
                    description: diagnosisViewModel.isTestMode ? 
                        "Creating test recommendations..." : "Creating comprehensive diagnosis and recommendations"
                )
            case .complete:
                stepContent(
                    icon: "checkmark.circle.fill",
                    title: "Analysis Complete",
                    description: "Ready to view detailed results"
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
                Text("Current Step: \(currentStep.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                ForEach(currentStep.detailedTasks(isTestMode: diagnosisViewModel.isTestMode), id: \.self) { task in
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
                .fill(Color(UIColor.systemBackground))
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
        let stepDuration: Double = diagnosisViewModel.isTestMode ? 1.2 : 3.0
        let steps = GenerationStep.allCases
        
        for (index, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * stepDuration) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = step
                    animationProgress = Double(index + 1) / Double(steps.count)
                    generationProgress = step.progressMessage(isTestMode: diagnosisViewModel.isTestMode)
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
        let tasks = step.detailedTasks(isTestMode: diagnosisViewModel.isTestMode)
        let taskDuration: Double = diagnosisViewModel.isTestMode ? 0.2 : 0.5
        
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
        if diagnosisViewModel.isTestMode {
            // Generate test diagnosis
            diagnosisViewModel.createTestDiagnosis { [weak diagnosisViewModel] in
                if let latestDiagnosis = diagnosisViewModel?.diagnoses.first {
                    onCompletion(latestDiagnosis)
                }
            }
        } else {
            // TODO: Integrate with real AI diagnosis service
            // For now, fallback to test diagnosis
            diagnosisViewModel.createTestDiagnosis { [weak diagnosisViewModel] in
                if let latestDiagnosis = diagnosisViewModel?.diagnoses.first {
                    onCompletion(latestDiagnosis)
                }
            }
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
        case .analyzing: return "Analyzing Sample"
        case .identifying: return "Identifying Issues"
        case .generating: return "Generating Diagnosis"
        case .complete: return "Analysis Complete"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .analyzing: return "Analyze"
        case .identifying: return "Identify"
        case .generating: return "Generate"
        case .complete: return "Complete"
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
    
    func progressMessage(isTestMode: Bool) -> String {
        if isTestMode {
            switch self {
            case .analyzing: return "Processing test image data..."
            case .identifying: return "Selecting mock deficiency scenario..."
            case .generating: return "Creating test recommendations..."
            case .complete: return "Test diagnosis ready!"
            }
        } else {
            switch self {
            case .analyzing: return "Examining plant characteristics..."
            case .identifying: return "Detecting potential health issues..."
            case .generating: return "Creating comprehensive analysis..."
            case .complete: return "Diagnosis complete!"
            }
        }
    }
    
    func detailedTasks(isTestMode: Bool) -> [String] {
        switch self {
        case .analyzing:
            if isTestMode {
                return [
                    "Loading test sample data",
                    "Applying mock environmental conditions",
                    "Simulating image processing",
                    "Generating synthetic measurements",
                    "Preparing analysis pipeline"
                ]
            } else {
                return [
                    "Processing captured images",
                    "Extracting plant features",
                    "Analyzing color patterns",
                    "Measuring leaf characteristics",
                    "Assessing overall structure"
                ]
            }
        case .identifying:
            if isTestMode {
                return [
                    "Running mock disease detection",
                    "Simulating nutrient analysis",
                    "Generating test deficiency patterns",
                    "Creating sample health metrics",
                    "Preparing diagnostic results"
                ]
            } else {
                return [
                    "Running disease detection algorithms",
                    "Analyzing nutrient deficiencies",
                    "Checking for pest indicators",
                    "Evaluating growth patterns",
                    "Cross-referencing plant database"
                ]
            }
        case .generating:
            if isTestMode {
                return [
                    "Compiling test diagnosis report",
                    "Generating mock recommendations",
                    "Creating sample treatment plan",
                    "Formatting test results",
                    "Finalizing demo report"
                ]
            } else {
                return [
                    "Compiling diagnosis results",
                    "Generating treatment recommendations",
                    "Creating action plan",
                    "Formatting comprehensive report",
                    "Validating final results"
                ]
            }
        case .complete:
            return [
                "Diagnosis report ready",
                "Recommendations compiled",
                "Action plan prepared"
            ]
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
