//
//  LanguageSelectionView.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 11/09/25.
//  Vista para seleccionar el idioma de la app
//

import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: AppLanguage
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguage)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Lista de idiomas
                List {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedLanguage = language
                            }
                        }) {
                            HStack(spacing: 16) {
                                // Icono del idioma
                                Text(language.icon)
                                    .font(.title2)
                                
                                // Nombre del idioma
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(language.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if language == languageManager.currentLanguage {
                                        Text(languageManager.localizedString("current_language"))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Checkmark para idioma seleccionado
                                if selectedLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                // Mensaje informativo para idiomas indígenas
                if selectedLanguage == .nahuatl || selectedLanguage == .maya {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Información importante")
                                .font(.headline)
                        }
                        
                        Text(getIndigenousLanguageNote())
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle(languageManager.localizedString("select_language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localizedString("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        languageManager.currentLanguage = selectedLanguage
                        dismiss()
                    }) {
                        Text(languageManager.localizedString("save"))
                            .fontWeight(.bold)
                    }
                    .disabled(selectedLanguage == languageManager.currentLanguage)
                }
            }
        }
    }
    
    private func getIndigenousLanguageNote() -> String {
        switch selectedLanguage {
        case .nahuatl:
            return "Las traducciones al náhuatl están basadas en la variante del centro de México. Estamos trabajando con hablantes nativos para incluir variantes regionales de Chiapas."
        case .maya:
            return "Las traducciones están en maya yucateco. Próximamente incluiremos variantes de lenguas mayas de Chiapas como tseltal y tsotsil."
        default:
            return ""
        }
    }
}

struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView()
    }
}
