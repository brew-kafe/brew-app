//
//  BrewAssistantManager.swift
//  brew
//
//  AI Assistant for coffee and tech technicians
//  Created by Humbe on 15/10/25.
//
import Foundation
import Combine
import os.log

@MainActor
class BrewAssistantManager: ObservableObject {
    static let shared = BrewAssistantManager()
    
    // MARK: - Published Properties
    @Published var conversationHistory: [ConversationMessage] = []
    @Published var isProcessing = false
    @Published var currentLanguage: AppLanguage = .spanish
    @Published var autoTranslate = true
    
    // Dependencies
    private let translator = TsotsilMLXTranslator.shared
    private let logger = Logger(subsystem: "com.brew.app", category: "Assistant")
    
    // Context tracking
    private var userContext: UserContext = UserContext()
    
    private init() {
        loadConversationHistory()
    }
    
    // MARK: - Main Processing
    
    /// Process user message and generate response
    func processMessage(_ message: String) async -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        // Detect if message is in Tsotsil
        let isTsotsil = translator.detectTsotsil(message)
        
        // Translate if needed
        let processedMessage: String
        if isTsotsil && autoTranslate {
            processedMessage = await translator.translateFromTsotsil(message)
            logger.info("Translated from Tsotsil: \(message) -> \(processedMessage)")
        } else {
            processedMessage = message
        }
        
        // Add user message to history
        let userMessage = ConversationMessage(
            content: message,
            isFromUser: true,
            timestamp: Date(),
            language: isTsotsil ? .tsotsil : currentLanguage
        )
        conversationHistory.append(userMessage)
        
        // Analyze intent and generate response
        let intent = analyzeIntent(processedMessage)
        let response = await generateResponse(for: processedMessage, intent: intent)
        
        // Translate response back to Tsotsil if needed
        let finalResponse: String
        if isTsotsil && autoTranslate {
            finalResponse = await translator.translateToTsotsil(response)
            logger.info("Translated to Tsotsil: \(response) -> \(finalResponse)")
        } else {
            finalResponse = response
        }
        
        // Add assistant response to history
        let assistantMessage = ConversationMessage(
            content: finalResponse,
            isFromUser: false,
            timestamp: Date(),
            language: isTsotsil ? .tsotsil : currentLanguage
        )
        conversationHistory.append(assistantMessage)
        
        saveConversationHistory()
        
        return finalResponse
    }
    
    // MARK: - Intent Analysis
    
    func analyzeIntent(_ message: String) -> MessageIntent {
        let lowercased = message.lowercased()
        
        // Coffee-related intents
        if lowercased.contains("café") || lowercased.contains("coffee") ||
           lowercased.contains("planta") || lowercased.contains("plant") {
            if lowercased.contains("enfermedad") || lowercased.contains("disease") ||
               lowercased.contains("plaga") || lowercased.contains("pest") {
                return .coffeeDiseaseHelp
            } else if lowercased.contains("cosecha") || lowercased.contains("harvest") {
                return .harvestAdvice
            } else if lowercased.contains("clima") || lowercased.contains("weather") {
                return .weatherImpact
            }
            return .coffeeGeneral
        }
        
        // Technical support intents
        if lowercased.contains("app") || lowercased.contains("aplicación") ||
           lowercased.contains("error") || lowercased.contains("problema") ||
           lowercased.contains("ayuda") || lowercased.contains("help") {
            return .technicalSupport
        }
        
        // Report-related intents
        if lowercased.contains("reporte") || lowercased.contains("report") ||
           lowercased.contains("parcela") || lowercased.contains("location") {
            return .reportInquiry
        }
        
        // Cooperative management
        if lowercased.contains("cooperativa") || lowercased.contains("cooperative") ||
           lowercased.contains("miembros") || lowercased.contains("members") {
            return .cooperativeManagement
        }
        
        // Greetings
        if lowercased.contains("hola") || lowercased.contains("hello") ||
           lowercased.contains("buenos días") || lowercased.contains("good morning") {
            return .greeting
        }
        
        return .general
    }
    
    // MARK: - Response Generation
    
    private func generateResponse(for message: String, intent: MessageIntent) async -> String {
        switch intent {
        case .greeting:
            return generateGreeting()
            
        case .coffeeGeneral:
            return """
            Puedo ayudarte con información sobre el cultivo de café. ¿Qué necesitas saber?
            
            Puedo ayudarte con:
            • Identificación de plagas y enfermedades
            • Consejos de cosecha
            • Impacto del clima
            • Mejores prácticas de cultivo
            """
            
        case .coffeeDiseaseHelp:
            return """
            Para ayudarte con enfermedades del café, necesito más información:
            
            ¿Qué síntomas observas?
            • Manchas en las hojas
            • Pudrición de raíces
            • Hongos en el tronco
            • Pérdida de hojas
            
            También puedes crear un reporte en la sección de Parcelas para documentar el problema.
            """
            
        case .harvestAdvice:
            return """
            Consejos para la cosecha de café:
            
            🍒 **Momento óptimo**: Los frutos deben estar completamente rojos
            
            ✋ **Técnica**: Cosecha selectiva, solo los frutos maduros
            
            📦 **Post-cosecha**: Procesa los frutos dentro de las primeras 24 horas
            
            🌡️ **Clima**: Evita cosechar con lluvia o rocío excesivo
            
            ¿Necesitas información específica sobre algún aspecto?
            """
            
        case .weatherImpact:
            return """
            El clima afecta significativamente el cultivo de café:
            
            ☀️ **Sol**: 4-6 horas diarias óptimo
            🌧️ **Lluvia**: 1,500-2,000mm anuales ideal
            🌡️ **Temperatura**: 18-24°C rango óptimo
            
            ¿Quieres información sobre cómo proteger tu cultivo del clima actual?
            """
            
        case .technicalSupport:
            return """
            Estoy aquí para ayudarte con la aplicación brew:
            
            📱 **Funciones principales**:
            • Gestión de parcelas
            • Creación de reportes
            • Visualización de mapas
            • Exportación de datos
            
            ¿Con qué función específica necesitas ayuda?
            """
            
        case .reportInquiry:
            return """
            En brew puedes gestionar reportes de tus parcelas:
            
            1. Ve a la sección de "Parcelas"
            2. Selecciona una parcela en el mapa
            3. Toca "Crear Reporte"
            4. Completa los campos necesarios
            5. Añade fotos si es necesario
            
            ¿Necesitas ayuda con un reporte específico?
            """
            
        case .cooperativeManagement:
            return """
            Gestión de cooperativas en brew:
            
            👥 **Miembros**: Ve a Configuración > Cooperativa
            📊 **Estadísticas**: Revisa el tablero de control
            📄 **Reportes**: Exporta datos de toda la cooperativa
            
            ¿Qué aspecto de la gestión necesitas manejar?
            """
            
        case .general:
            return generateContextualResponse(for: message)
        }
    }
    
    private func generateGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        
        switch hour {
        case 5..<12:
            timeGreeting = currentLanguage == .tsotsil ? "Lec totique" : "Buenos días"
        case 12..<19:
            timeGreeting = currentLanguage == .tsotsil ? "Lec ac'obale" : "Buenas tardes"
        default:
            timeGreeting = currentLanguage == .tsotsil ? "Lec ac'obale" : "Buenas noches"
        }
        
        return """
        \(timeGreeting)! Soy tu asistente de brew 🌱
        
        Estoy aquí para ayudarte con:
        • Cultivo y cuidado del café
        • Problemas técnicos de la app
        • Gestión de parcelas y reportes
        • Información sobre tu cooperativa
        
        ¿En qué puedo ayudarte hoy?
        """
    }
    
    private func generateContextualResponse(for message: String) -> String {
        // Use conversation history for context
        let recentMessages = conversationHistory.suffix(5)
        
        // Check if we've discussed coffee recently
        let discussedCoffee = recentMessages.contains { msg in
            msg.content.lowercased().contains("café") || 
            msg.content.lowercased().contains("coffee")
        }
        
        if discussedCoffee {
            return "¿Hay algo más sobre el cultivo de café en lo que pueda ayudarte?"
        }
        
        return """
        Entiendo tu pregunta. Como asistente técnico de brew, puedo ayudarte con:
        
        ☕ **Café**: Cultivo, plagas, cosecha
        📱 **App**: Funciones y soporte técnico
        📍 **Parcelas**: Gestión y reportes
        🤝 **Cooperativa**: Administración y datos
        
        ¿Podrías darme más detalles sobre lo que necesitas?
        """
    }
    
    // MARK: - Quick Actions
    
    func getQuickActions() -> [QuickAction] {
        return [
            QuickAction(
                id: "coffee_help",
                icon: "leaf.fill",
                title: currentLanguage == .tsotsil ? "Café" : "Ayuda con Café",
                prompt: "¿Cómo puedo cuidar mejor mis plantas de café?"
            ),
            QuickAction(
                id: "disease_check",
                icon: "cross.case.fill",
                title: currentLanguage == .tsotsil ? "K'ux" : "Revisar Enfermedad",
                prompt: "¿Qué enfermedades comunes afectan al café?"
            ),
            QuickAction(
                id: "harvest_time",
                icon: "calendar",
                title: currentLanguage == .tsotsil ? "Cosecha" : "Tiempo de Cosecha",
                prompt: "¿Cuándo debo cosechar mi café?"
            ),
            QuickAction(
                id: "app_help",
                icon: "app.badge.checkmark",
                title: currentLanguage == .tsotsil ? "App" : "Ayuda con App",
                prompt: "¿Cómo uso las funciones de brew?"
            ),
            QuickAction(
                id: "create_report",
                icon: "doc.text",
                title: currentLanguage == .tsotsil ? "Reporte" : "Crear Reporte",
                prompt: "¿Cómo creo un reporte de mi parcela?"
            ),
            QuickAction(
                id: "weather",
                icon: "cloud.sun",
                title: currentLanguage == .tsotsil ? "K'ok'al" : "Clima",
                prompt: "¿Cómo afecta el clima a mi cultivo?"
            )
        ]
    }
    
    // MARK: - Persistence
    
    private func saveConversationHistory() {
        if let encoded = try? JSONEncoder().encode(conversationHistory) {
            UserDefaults.standard.set(encoded, forKey: "conversationHistory")
        }
    }
    
    private func loadConversationHistory() {
        guard let data = UserDefaults.standard.data(forKey: "conversationHistory"),
              let decoded = try? JSONDecoder().decode([ConversationMessage].self, from: data) else {
            return
        }
        conversationHistory = decoded
    }
    
    func clearHistory() {
        conversationHistory.removeAll()
        saveConversationHistory()
    }
}

// MARK: - Supporting Types

struct ConversationMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let language: AppLanguage
    
    init(content: String, isFromUser: Bool, timestamp: Date, language: AppLanguage) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.language = language
    }
}

enum MessageIntent {
    case greeting
    case coffeeGeneral
    case coffeeDiseaseHelp
    case harvestAdvice
    case weatherImpact
    case technicalSupport
    case reportInquiry
    case cooperativeManagement
    case general
}

struct QuickAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let prompt: String
}

struct UserContext {
    var preferredLanguage: AppLanguage = .spanish
    var recentTopics: [String] = []
    var lastInteraction: Date?
}
