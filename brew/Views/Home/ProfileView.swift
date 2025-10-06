//
//  ProfileView.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 30/09/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    
    // MARK: - User profile data
    let avatars = ["MALE", "FEMALE"]
    @State private var selectedAvatar = "MALE"
    @State private var userName: String = ""
    @State private var backgroundColor: Color = .brown.opacity(0.3)
    
    // MARK: - Agricultural data
    @State private var cropType: String = ""
    @State private var soilType: String = ""
    @State private var landSize: String = ""
    
    // MARK: - Preferences
    @State private var notificationsEnabled = true
    @State private var showSaveConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // MARK: - Avatar Section
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(backgroundColor.opacity(0.3))
                            .frame(width: 180, height: 180)
                            .shadow(color: .brown.opacity(0.3), radius: 10)
                        
                        Image(selectedAvatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }
                    
                    Picker("Avatar", selection: $selectedAvatar) {
                        ForEach(avatars, id: \.self) { avatar in
                            Text(avatar)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    ColorPicker("Color de fondo", selection: $backgroundColor)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .shadow(color: .brown.opacity(0.1), radius: 3)
                
                // MARK: - Personal Info
                sectionCard(title: "Información Personal") {
                    profileField(icon: "person.text.rectangle", placeholder: "Nombre completo", text: $userName)
                }
                
                // MARK: - Agricultural Info
                sectionCard(title: "Datos Agrícolas") {
                    profileField(icon: "leaf.fill", placeholder: "Tipo de cultivo", text: $cropType)
                    profileField(icon: "mountain.2.fill", placeholder: "Tipo de suelo", text: $soilType)
                    profileField(icon: "map.fill", placeholder: "Tamaño del terreno (ha)", text: $landSize, keyboard: .decimalPad)
                }
                
                // MARK: - Preferences
                sectionCard(title: "Preferencias") {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.brown)
                            Text(notificationsEnabled ? "Notificaciones Activadas" : "Notificaciones Desactivadas")
                        }
                    }
                    .tint(.brown)
                }
                
                // MARK: - Save Button
                Button(action: saveProfile) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Guardar Cambios")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(12)
                    .shadow(color: .brown.opacity(0.4), radius: 5)
                }
                .padding(.horizontal)
                .alert("Perfil guardado con éxito", isPresented: $showSaveConfirmation) {
                    Button("OK", role: .cancel) { }
                }
            }
            .padding()
        }
        .navigationTitle(languageManager.localizedString("edit_profile"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Reusable Components
    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            VStack(spacing: 10, content: content)
                .padding(.horizontal)
        }
        .padding(.vertical, 15)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(color: .brown.opacity(0.1), radius: 3)
    }
    
    private func profileField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brown)
                .frame(width: 25)
            TextField(placeholder, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboard)
        }
    }
    
    // MARK: - Save Logic
    private func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
        UserDefaults.standard.set(cropType, forKey: "cropType")
        UserDefaults.standard.set(soilType, forKey: "soilType")
        UserDefaults.standard.set(landSize, forKey: "landSize")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        
        showSaveConfirmation = true
        print("✅ Profile saved successfully")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
