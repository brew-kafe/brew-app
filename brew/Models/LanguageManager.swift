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
    case german = "de"
    case japanese = "ja"
    case catalan = "ca"
    case french = "fr"
    case tsotsil = "tzo"
    
    var displayName: String {
        switch self {
        case .spanish: return "Español"
        case .english: return "English"
        case .nahuatl: return "Náhuatl"
        case .maya: return "Maya Yucateco"
        case .german: return "Deutsch"
        case .japanese: return "日本語"
        case .catalan: return "Català"
        case .french: return "Français"
        case .tsotsil: return "Tsotsil"
        }
    }
    
    var icon: String {
        switch self {
        case .spanish: return "🇲🇽"
        case .english: return "🇺🇸"
        case .nahuatl: return "🏛️"
        case .maya: return "🗿"
        case .german: return "🇩🇪"
        case .japanese: return "🇯🇵"
        case .catalan: return "🏴"
        case .french: return "🇫🇷"
        case .tsotsil: return "🌽"
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
        // Settings Section
        "settings": [
            .spanish: "Configuración",
            .english: "Settings",
            .nahuatl: "Tlayecanaliztli",
            .maya: "Nu'ukbesajil",
            .german: "Einstellungen",
            .japanese: "設定",
            .catalan: "Configuració",
            .french: "Paramètres",
            .tsotsil: "Smelolal"
        ],
        
        // Profile Section
        "profile": [
            .spanish: "Perfil",
            .english: "Profile",
            .nahuatl: "Motlacayo",
            .maya: "A wíinikil",
            .german: "Profil",
            .japanese: "プロフィール",
            .catalan: "Perfil",
            .french: "Profil",
            .tsotsil: "Sbijilal"
        ],
        "edit_profile": [
            .spanish: "Editar Perfil",
            .english: "Edit Profile",
            .nahuatl: "Ticpatlas Motlacayo",
            .maya: "K'éexik a wíinikil",
            .german: "Profil bearbeiten",
            .japanese: "プロフィール編集",
            .catalan: "Editar Perfil",
            .french: "Modifier le profil",
            .tsotsil: "Jelel sbijilal"
        ],
        
        // Notifications Section
        "notifications": [
            .spanish: "Notificaciones",
            .english: "Notifications",
            .nahuatl: "Tetlanonotzalizmeh",
            .maya: "A'almajt'aano'ob",
            .german: "Benachrichtigungen",
            .japanese: "通知",
            .catalan: "Notificacions",
            .french: "Notifications",
            .tsotsil: "Sk'elel k'op"
        ],
        "alerts": [
            .spanish: "Alertas",
            .english: "Alerts",
            .nahuatl: "Tenahuatiliztli",
            .maya: "K'a'ajsajil",
            .german: "Warnungen",
            .japanese: "アラート",
            .catalan: "Alertes",
            .french: "Alertes",
            .tsotsil: "K'asesel"
        ],
        
        // Preferences Section
        "preferences": [
            .spanish: "Preferencias",
            .english: "Preferences",
            .nahuatl: "Tlen Ticnequi",
            .maya: "Ba'ax ka wóojel",
            .german: "Einstellungen",
            .japanese: "環境設定",
            .catalan: "Preferències",
            .french: "Préférences",
            .tsotsil: "K'an chalel"
        ],
        "language_region": [
            .spanish: "Idioma y Región",
            .english: "Language & Region",
            .nahuatl: "Totlahtol ihuan Tochan",
            .maya: "T'aan yéetel lu'um",
            .german: "Sprache & Region",
            .japanese: "言語と地域",
            .catalan: "Idioma i regió",
            .french: "Langue et région",
            .tsotsil: "K'op xchi'uk lum"
        ],
        "theme": [
            .spanish: "Tema",
            .english: "Theme",
            .nahuatl: "Quenin Neci",
            .maya: "Bix u yila'al",
            .german: "Design",
            .japanese: "テーマ",
            .catalan: "Tema",
            .french: "Thème",
            .tsotsil: "Stalel"
        ],
        "feedback_support": [
            .spanish: "Comentarios y Soporte",
            .english: "Feedback & Support",
            .nahuatl: "Motlahtol ihuan Tepalehuiliztli",
            .maya: "A t'aan yéetel áantaj",
            .german: "Feedback & Support",
            .japanese: "フィードバックとサポート",
            .catalan: "Comentaris i suport",
            .french: "Commentaires et support",
            .tsotsil: "K'op xchi'uk koltayel"
        ],
        "faq": [
            .spanish: "Preguntas Frecuentes",
            .english: "FAQ",
            .nahuatl: "Tlamantli Motlatlanilia",
            .maya: "K'áat chi'ob suukilo'ob",
            .german: "Häufige Fragen",
            .japanese: "よくある質問",
            .catalan: "Preguntes freqüents",
            .french: "FAQ",
            .tsotsil: "Jajch' k'ucha'al"
        ],
        
        // General Section
        "general": [
            .spanish: "General",
            .english: "General",
            .nahuatl: "Nochi",
            .maya: "Tuláakal",
            .german: "Allgemein",
            .japanese: "一般",
            .catalan: "General",
            .french: "Général",
            .tsotsil: "Skotol"
        ],
        "about_brew": [
            .spanish: "Acerca de Brew",
            .english: "About Brew",
            .nahuatl: "Ipan Brew",
            .maya: "Yo'osal Brew",
            .german: "Über Brew",
            .japanese: "Brewについて",
            .catalan: "Sobre Brew",
            .french: "À propos de Brew",
            .tsotsil: "Yu'un Brew"
        ],
        "log_out": [
            .spanish: "Cerrar Sesión",
            .english: "Log Out",
            .nahuatl: "Tiquizaz",
            .maya: "Jóok'ol",
            .german: "Abmelden",
            .japanese: "ログアウト",
            .catalan: "Tancar sessió",
            .french: "Déconnexion",
            .tsotsil: "Lok'el"
        ],
        
        // Language Selection
        "select_language": [
            .spanish: "Seleccionar Idioma",
            .english: "Select Language",
            .nahuatl: "Xicpehpena Totlahtol",
            .maya: "Xéet' t'aan",
            .german: "Sprache wählen",
            .japanese: "言語を選択",
            .catalan: "Seleccionar idioma",
            .french: "Sélectionner la langue",
            .tsotsil: "Cha' k'op"
        ],
        "save": [
            .spanish: "Guardar",
            .english: "Save",
            .nahuatl: "Ticpiyaz",
            .maya: "Táakbesa'al",
            .german: "Speichern",
            .japanese: "保存",
            .catalan: "Desar",
            .french: "Enregistrer",
            .tsotsil: "Maliyel"
        ],
        "cancel": [
            .spanish: "Cancelar",
            .english: "Cancel",
            .nahuatl: "Ticpoloz",
            .maya: "P'atik",
            .german: "Abbrechen",
            .japanese: "キャンセル",
            .catalan: "Cancel·lar",
            .french: "Annuler",
            .tsotsil: "Makal"
        ],
        "current_language": [
            .spanish: "Idioma actual",
            .english: "Current language",
            .nahuatl: "Axcan totlahtol",
            .maya: "Bejla'e' t'aan",
            .german: "Aktuelle Sprache",
            .japanese: "現在の言語",
            .catalan: "Idioma actual",
            .french: "Langue actuelle",
            .tsotsil: "Ora li' k'op"
        ],
        
        // Additional common strings for expansion
        "welcome": [
            .spanish: "Bienvenido",
            .english: "Welcome",
            .nahuatl: "Ximopanolti",
            .maya: "Uts a wóotel",
            .german: "Willkommen",
            .japanese: "ようこそ",
            .catalan: "Benvingut",
            .french: "Bienvenue",
            .tsotsil: "Lek oy a talelal"
        ],
        "home": [
            .spanish: "Inicio",
            .english: "Home",
            .nahuatl: "Tochan",
            .maya: "Najil",
            .german: "Start",
            .japanese: "ホーム",
            .catalan: "Inici",
            .french: "Accueil",
            .tsotsil: "Na"
        ],
        "search": [
            .spanish: "Buscar",
            .english: "Search",
            .nahuatl: "Tictemoz",
            .maya: "Kaxtik",
            .german: "Suchen",
            .japanese: "検索",
            .catalan: "Cercar",
            .french: "Rechercher",
            .tsotsil: "Sa'el"
        ],
        "yes": [
            .spanish: "Sí",
            .english: "Yes",
            .nahuatl: "Quema",
            .maya: "Je'el",
            .german: "Ja",
            .japanese: "はい",
            .catalan: "Sí",
            .french: "Oui",
            .tsotsil: "Ja'"
        ],
        "no": [
            .spanish: "No",
            .english: "No",
            .nahuatl: "Amo",
            .maya: "Ma'",
            .german: "Nein",
            .japanese: "いいえ",
            .catalan: "No",
            .french: "Non",
            .tsotsil: "Mu"
        ]
    ]
    
    func getString(for key: String, language: AppLanguage) -> String {
        return translations[key]?[language] ?? key
    }
    
    // Method to get all keys for documentation
    func getAllTranslationKeys() -> [String] {
        return Array(translations.keys).sorted()
    }
    
    // Method to check if a key has all language translations
    func isKeyFullyTranslated(_ key: String) -> Bool {
        guard let keyTranslations = translations[key] else { return false }
        return keyTranslations.count == AppLanguage.allCases.count
    }
}
