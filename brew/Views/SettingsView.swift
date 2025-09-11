//
//  SettingsView.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 10/09/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var showingLanguageSelection = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile
                Section(header: Text(languageManager.localizedString("profile"))) {
                    Button(action: {
                        // Acción para editar perfil
                    }) {
                        HStack {
                            Label(languageManager.localizedString("edit_profile"),
                                  systemImage: "person.crop.circle.fill")
                                .foregroundColor(.brown)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Notifications
                Section(header: Text(languageManager.localizedString("notifications"))) {
                    Button(action: {
                        // Acción para alertas
                    }) {
                        HStack {
                            Label(languageManager.localizedString("alerts"),
                                  systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Preferences
                Section(header: Text(languageManager.localizedString("preferences"))) {
                    // Botón de Idioma - AHORA FUNCIONAL
                    Button(action: {
                        showingLanguageSelection = true
                    }) {
                        HStack {
                            Label(languageManager.localizedString("language_region"),
                                  systemImage: "globe")
                                .foregroundColor(.brown)
                            Spacer()
                            
                            // Muestra el idioma actual
                            HStack(spacing: 4) {
                                Text(languageManager.currentLanguage.icon)
                                    .font(.caption)
                                Text(languageManager.currentLanguage.displayName)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Acción para tema
                    }) {
                        HStack {
                            Label(languageManager.localizedString("theme"),
                                  systemImage: "circle.lefthalf.filled")
                                .foregroundColor(.brown)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Acción para feedback
                    }) {
                        HStack {
                            Label(languageManager.localizedString("feedback_support"),
                                  systemImage: "bubble.left.and.text.bubble.right.fill")
                                .foregroundColor(.brown)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Acción para FAQ
                    }) {
                        HStack {
                            Label(languageManager.localizedString("faq"),
                                  systemImage: "questionmark.circle")
                                .foregroundColor(.brown)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // General
                Section(header: Text(languageManager.localizedString("general"))) {
                    Button(action: {
                        // Acción para About
                    }) {
                        HStack {
                            Label(languageManager.localizedString("about_brew"),
                                  systemImage: "book")
                                .foregroundColor(.brown)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Acción para Log Out
                    }) {
                        HStack {
                            Label(languageManager.localizedString("log_out"),
                                  systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.brown)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle(languageManager.localizedString("settings"))
            .listSectionSpacing(15)
            .sheet(isPresented: $showingLanguageSelection) {
                LanguageSelectionView()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
