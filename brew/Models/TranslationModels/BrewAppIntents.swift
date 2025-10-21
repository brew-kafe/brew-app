//
//  BrewAppIntents.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 15/10/25.
//  Siri & Shortcuts integration for brew AI Assistant
//

import Foundation
import AppIntents

// MARK: - Ask Brew Assistant Intent

@available(iOS 16.0, *)
struct AskBrewAssistantIntent: AppIntent {
    static var title: LocalizedStringResource = "Pregunta al Asistente brew"
    static var description = IntentDescription("Pregunta al asistente de IA sobre café, cultivo o la app brew")
    
    @Parameter(title: "Pregunta", description: "Tu pregunta para el asistente")
    var question: String
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let assistant = await BrewAssistantManager.shared
        let response = await assistant.processMessage(question)
        
        return .result(value: response)
    }
}

// MARK: - Get Coffee Advice Intent

@available(iOS 16.0, *)
struct GetCoffeeAdviceIntent: AppIntent {
    static var title: LocalizedStringResource = "Obtener Consejos de Café"
    static var description = IntentDescription("Obtén consejos sobre el cultivo de café")
    
    @Parameter(title: "Tema", description: "Tema específico sobre el café")
    var topic: CoffeeTopic
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let assistant = await BrewAssistantManager.shared
        
        let question: String
        switch topic {
        case .disease:
            question = "¿Qué enfermedades comunes afectan al café?"
        case .harvest:
            question = "¿Cuándo debo cosechar mi café?"
        case .weather:
            question = "¿Cómo afecta el clima a mi cultivo?"
        case .general:
            question = "Dame consejos generales sobre el cultivo de café"
        }
        
        let response = await assistant.processMessage(question)
        return .result(value: response)
    }
}

enum CoffeeTopic: String, AppEnum {
    case disease = "Enfermedades"
    case harvest = "Cosecha"
    case weather = "Clima"
    case general = "General"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Tema de Café"
    static var caseDisplayRepresentations: [CoffeeTopic: DisplayRepresentation] = [
        .disease: "Enfermedades y Plagas",
        .harvest: "Tiempo de Cosecha",
        .weather: "Impacto del Clima",
        .general: "Consejos Generales"
    ]
}

// MARK: - Check Plant Health Intent

@available(iOS 16.0, *)
struct CheckPlantHealthIntent: AppIntent {
    static var title: LocalizedStringResource = "Verificar Salud de Plantas"
    static var description = IntentDescription("Consulta sobre la salud de tus plantas de café")
    
    @Parameter(title: "Síntomas", description: "Describe los síntomas que observas")
    var symptoms: String
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let assistant = await BrewAssistantManager.shared
        let question = "Mis plantas de café tienen estos síntomas: \(symptoms). ¿Qué podría ser?"
        
        let response = await assistant.processMessage(question)
        return .result(value: response)
    }
}

// MARK: - Quick Translation Intent

@available(iOS 16.0, *)
struct TranslateToTsotsilIntent: AppIntent {
    static var title: LocalizedStringResource = "Traducir a Tsotsil"
    static var description = IntentDescription("Traduce texto de español a Tsotsil")
    
    @Parameter(title: "Texto", description: "Texto a traducir")
    var text: String
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let translator = TsotsilMLXTranslator.shared
        let translation = await translator.translateToTsotsil(text)
        
        return .result(value: translation)
    }
}

// MARK: - App Shortcuts Provider

@available(iOS 16.0, *)
struct BrewAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AskBrewAssistantIntent(),
            phrases: [
                "Pregunta a \(.applicationName)",
                "Consulta \(.applicationName)",
                "Ayuda de \(.applicationName)"
            ],
            shortTitle: "Preguntar",
            systemImageName: "leaf.fill"
        )
        
        AppShortcut(
            intent: GetCoffeeAdviceIntent(),
            phrases: [
                "Consejos de café en \(.applicationName)",
                "Ayuda con mi café",
                "Cultivo de café"
            ],
            shortTitle: "Consejos Café",
            systemImageName: "cup.and.saucer.fill"
        )
        
        AppShortcut(
            intent: CheckPlantHealthIntent(),
            phrases: [
                "Revisar salud de plantas",
                "Mis plantas están enfermas",
                "Verificar café"
            ],
            shortTitle: "Verificar Salud",
            systemImageName: "cross.case.fill"
        )
    }
}

// MARK: - Widget Intents

@available(iOS 16.0, *)
struct GetRecentReportsIntent: AppIntent {
    static var title: LocalizedStringResource = "Obtener Reportes Recientes"
    static var description = IntentDescription("Obtén tus reportes más recientes de parcelas")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // This would integrate with your ReportViewModel
        // For now, return success
        return .result()
    }
}

@available(iOS 16.0, *)
struct QuickReportIntent: AppIntent {
    static var title: LocalizedStringResource = "Crear Reporte Rápido"
    static var description = IntentDescription("Crea un reporte rápido de tu parcela")
    
    @Parameter(title: "Notas", description: "Notas del reporte")
    var notes: String
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // This would create a quick report
        return .result()
    }
}
