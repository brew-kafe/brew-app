//
//  LanguageManager.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 10/09/25.
//  Sistema de gestión de idiomas para la app
//
//

import Foundation
import SwiftUI

// Enum de Idiomas Disponibles
enum AppLanguage: String, CaseIterable {
    case spanish = "es"
    case english = "en"
    case nahuatl = "nah"
    case maya = "may"
    
    var displayName: String {
        switch self {
        case .spanish: return "Español"
        case .english: return "English"
        case .nahuatl: return "Náhuatl"
        case .maya: return "Maya Yucateco"
        }
    }
    
    var icon: String {
        switch self {
        case .spanish: return "🇲🇽"
        case .english: return "🇺🇸"
        case .nahuatl: return "🏛️"
        case .maya: return "🗿"
        }
    }
}

//  Gestor Principal de Idiomas
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            objectWillChange.send()
        }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "es"
        self.currentLanguage = AppLanguage(rawValue: savedLanguage) ?? .spanish
    }
    
    func localizedString(_ key: String) -> String {
        return LocalizationService.shared.getString(for: key, language: currentLanguage)
    }
}

//  Servicio de Localización
class LocalizationService {
    static let shared = LocalizationService()
    
    private let translations: [String: [AppLanguage: String]] = [
        "settings": [
            .spanish: "Configuración",
            .english: "Settings",
            .nahuatl: "Tlayecanaliztli",
            .maya: "Nu'ukbesajil"
        ],
        
        "profile": [
            .spanish: "Perfil",
            .english: "Profile",
            .nahuatl: "Motlacayo",
            .maya: "A wíinikil"
        ],
        "edit_profile": [
            .spanish: "Editar Perfil",
            .english: "Edit Profile",
            .nahuatl: "Ticpatlas Motlacayo",
            .maya: "K'éexik a wíinikil"
        ],
        
        "notifications": [
            .spanish: "Notificaciones",
            .english: "Notifications",
            .nahuatl: "Tetlanonotzalizmeh",
            .maya: "A'almajt'aano'ob"
        ],
        "alerts": [
            .spanish: "Alertas",
            .english: "Alerts",
            .nahuatl: "Tenahuatiliztli",
            .maya: "K'a'ajsajil"
        ],
        
        "preferences": [
            .spanish: "Preferencias",
            .english: "Preferences",
            .nahuatl: "Tlen Ticnequi",
            .maya: "Ba'ax ka wóojel"
        ],
        "language_region": [
            .spanish: "Idioma y Región",
            .english: "Language & Region",
            .nahuatl: "Totlahtol ihuan Tochan",
            .maya: "T'aan yéetel lu'um"
        ],
        "theme": [
            .spanish: "Tema",
            .english: "Theme",
            .nahuatl: "Quenin Neci",
            .maya: "Bix u yila'al"
        ],
        "feedback_support": [
            .spanish: "Comentarios y Soporte",
            .english: "Feedback & Support",
            .nahuatl: "Motlahtol ihuan Tepalehuiliztli",
            .maya: "A t'aan yéetel áantaj"
        ],
        "faq": [
            .spanish: "Preguntas Frecuentes",
            .english: "FAQ",
            .nahuatl: "Tlamantli Motlatlanilia",
            .maya: "K'áat chi'ob suukilo'ob"
        ],
        
        "general": [
            .spanish: "General",
            .english: "General",
            .nahuatl: "Nochi",
            .maya: "Tuláakal"
        ],
        "about_brew": [
            .spanish: "Acerca de Brew",
            .english: "About Brew",
            .nahuatl: "Ipan Brew",
            .maya: "Yo'osal Brew"
        ],
        "log_out": [
            .spanish: "Cerrar Sesión",
            .english: "Log Out",
            .nahuatl: "Tiquizaz",
            .maya: "Jóok'ol"
        ],
        
        "select_language": [
            .spanish: "Seleccionar Idioma",
            .english: "Select Language",
            .nahuatl: "Xicpehpena Totlahtol",
            .maya: "Xéet' t'aan"
        ],
        "save": [
            .spanish: "Guardar",
            .english: "Save",
            .nahuatl: "Ticpiyaz",
            .maya: "Táakbesa'al"
        ],
        "cancel": [
            .spanish: "Cancelar",
            .english: "Cancel",
            .nahuatl: "Ticpoloz",
            .maya: "P'atik"
        ],
        "current_language": [
            .spanish: "Idioma actual",
            .english: "Current language",
            .nahuatl: "Axcan totlahtol",
            .maya: "Bejla'e' t'aan"
        ]
    ]
    
    func getString(for key: String, language: AppLanguage) -> String {
        return translations[key]?[language] ?? key
    }
}
