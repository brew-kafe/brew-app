import SwiftUI

// MARK: - Modelo de Recomendación
struct CropRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: RecommendationCategory
    let priority: Priority
    let estimatedTime: String?
    let isCompleted: Bool
    
    enum RecommendationCategory {
        case watering, fertilizing, pest_control, harvesting, planting, pruning
        
        var icon: String {
            switch self {
            case .watering: return "drop.fill"
            case .fertilizing: return "leaf.fill"
            case .pest_control: return "bug.fill"
            case .harvesting: return "scissors"
            case .planting: return "seedling.fill"
            case .pruning: return "scissors.badge.ellipsis"
            }
        }
        
        var color: Color {
            switch self {
            case .watering: return .blue
            case .fertilizing: return .green
            case .pest_control: return .red
            case .harvesting: return .orange
            case .planting: return .brown
            case .pruning: return .purple
            }
        }
        
        var name: String {
            switch self {
            case .watering: return "Riego"
            case .fertilizing: return "Fertilización"
            case .pest_control: return "Control de Plagas"
            case .harvesting: return "Cosecha"
            case .planting: return "Siembra"
            case .pruning: return "Poda"
            }
        }
    }
    
    enum Priority {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .red
            }
        }
    }
}

// MARK: - Card de Recomendaciones
struct CropRecommendationsCard: View {
    @State private var recommendations: [CropRecommendation]
    @State private var showingAllRecommendations = false
    
    // Datos de ejemplo
    static let sampleRecommendations = [
        CropRecommendation(
            title: "Riego matutino recomendado",
            description: "Las temperaturas altas requieren riego temprano en Parcela A",
            category: .watering,
            priority: .high,
            estimatedTime: "30 min",
            isCompleted: false
        ),
        CropRecommendation(
            title: "Aplicar fertilizante orgánico",
            description: "Parcela B necesita nutrientes antes de la floración",
            category: .fertilizing,
            priority: .medium,
            estimatedTime: "1 hora",
            isCompleted: false
        ),
        CropRecommendation(
            title: "Inspección de plagas",
            description: "Revisar plantas en Parcela C por posibles infestaciones",
            category: .pest_control,
            priority: .medium,
            estimatedTime: "45 min",
            isCompleted: true
        ),
        CropRecommendation(
            title: "Cosecha de cerezas",
            description: "Las cerezas en la Parcela D están listas para cosechar",
            category: .harvesting,
            priority: .high,
            estimatedTime: "2 horas",
            isCompleted: false
        )
    ]
    
    init(recommendations: [CropRecommendation] = sampleRecommendations) {
        self._recommendations = State(initialValue: recommendations)
    }
    
    private var pendingRecommendations: [CropRecommendation] {
        recommendations.filter { !$0.isCompleted }
    }
    
    private var completedRecommendations: [CropRecommendation] {
        recommendations.filter { $0.isCompleted }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Recomendaciones")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !pendingRecommendations.isEmpty {
                    Text("\(pendingRecommendations.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    showingAllRecommendations.toggle()
                }) {
                    Image(systemName: showingAllRecommendations ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if recommendations.isEmpty {
                // Estado vacío
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("Sin recomendaciones")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Todos los cultivos están optimizados")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    // Recomendaciones pendientes
                    if !pendingRecommendations.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(showingAllRecommendations ? pendingRecommendations : Array(pendingRecommendations.prefix(2))) { recommendation in
                                RecommendationRow(recommendation: recommendation) { updatedRecommendation in
                                    updateRecommendation(updatedRecommendation)
                                }
                            }
                        }
                    }
                    
                    // Separador si hay completadas y pendientes
                    if !pendingRecommendations.isEmpty && !completedRecommendations.isEmpty && showingAllRecommendations {
                        Divider()
                            .padding(.vertical, 12)
                    }
                    
                    // Recomendaciones completadas (solo si se muestran todas)
                    if showingAllRecommendations && !completedRecommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completadas")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            VStack(spacing: 12) {
                                ForEach(completedRecommendations) { recommendation in
                                    RecommendationRow(recommendation: recommendation) { updatedRecommendation in
                                        updateRecommendation(updatedRecommendation)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Botón para mostrar más (solo si hay más de 2 pendientes)
                    if !showingAllRecommendations && pendingRecommendations.count > 2 {
                        Button(action: {
                            showingAllRecommendations = true
                        }) {
                            HStack {
                                Text("Ver \(pendingRecommendations.count - 2) más")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 12)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private func updateRecommendation(_ updatedRecommendation: CropRecommendation) {
        if let index = recommendations.firstIndex(where: { $0.id == updatedRecommendation.id }) {
            recommendations[index] = updatedRecommendation
        }
    }
}

// MARK: - Fila de Recomendación Individual
struct RecommendationRow: View {
    let recommendation: CropRecommendation
    let onUpdate: (CropRecommendation) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                let updated = CropRecommendation(
                    title: recommendation.title,
                    description: recommendation.description,
                    category: recommendation.category,
                    priority: recommendation.priority,
                    estimatedTime: recommendation.estimatedTime,
                    isCompleted: !recommendation.isCompleted
                )
                onUpdate(updated)
            }) {
                Image(systemName: recommendation.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(recommendation.isCompleted ? .green : .gray)
            }
            
            // Icono de categoría
            Image(systemName: recommendation.category.icon)
                .font(.body)
                .foregroundColor(recommendation.category.color)
                .frame(width: 20)
            
            // Contenido
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(recommendation.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(recommendation.isCompleted ? .secondary : .primary)
                        .strikethrough(recommendation.isCompleted)
                    
                    Spacer()
                    
                    if let time = recommendation.estimatedTime {
                        Text(time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                }
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Indicador de prioridad
            if !recommendation.isCompleted {
                Circle()
                    .fill(recommendation.priority.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CropRecommendationsCard()
        
        // Card vacía
        CropRecommendationsCard(recommendations: [])
    }
    .background(Color(.systemBackground))
}
