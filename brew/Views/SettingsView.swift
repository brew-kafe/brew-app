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
                            HStack(spacing: 10) {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.brown)
                                Text(languageManager.localizedString("edit_profile"))
                                    .foregroundColor(.black)
                            }
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
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(languageManager.localizedString("alerts"))
                                    .foregroundColor(.black)
                            }
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
                            HStack(spacing: 10) {
                                Image(systemName: "globe")
                                    .foregroundColor(.brown)
                                Text(languageManager.localizedString("language_region"))
                                    .foregroundColor(.black)
                            }
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
                        // Acción para feedback
                    }) {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                                    .foregroundColor(.brown)
                                Text(languageManager.localizedString("feedback_support"))
                                    .foregroundColor(.black)
                            }
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
                            HStack(spacing: 10) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.brown)
                                Text(languageManager.localizedString("faq"))
                                    .foregroundColor(.black)
                            }
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
                            HStack(spacing: 10) {
                                Image(systemName: "book")
                                    .foregroundColor(.brown)
                                Text(languageManager.localizedString("about_brew"))
                                    .foregroundColor(.black)
                            }
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
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.brown)
                                Text(languageManager.localizedString("log_out"))
                                    .foregroundColor(.black)
                            }
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
