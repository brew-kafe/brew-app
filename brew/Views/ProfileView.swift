//
//  ProfileView.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 30/09/25.
//
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    
    // User profile data
    // Memojis
    
    let avatars = ["MALE", "FEMALE",]
    @State private var selectedAvatar = "MALE"
    
    @State private var userName: String = ""
    @State private var backgroundColor: Color = .brown.opacity(0.3)
    
    // Agricultural data
    @State private var cropType: String = ""
    @State private var soilType: String = ""
    @State private var landSize: String = ""
    
    // Preferences
    @State private var notificationsEnabled = true
    
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    
                    // Profile Avatar Section
                    VStack(spacing: 12) {
                        Image(selectedAvatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .background(
                                Circle()
                                    .fill(backgroundColor.opacity(0.8))
                                    .frame(width: 160, height: 160)
                            )
                            .clipShape(Circle())
                            .shadow(color: .brown.opacity(0.3), radius: 10)
                            .padding(.top, -10)
                            .padding(.bottom, 10)
                        
                        // Avatar Picker
                        Picker("Elige tu avatar", selection: $selectedAvatar) {
                            ForEach(avatars, id: \.self) { avatar in
                                Text(avatar)
                            }
                        }
                        .padding(.bottom,2)
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Background Color Picker
                        ColorPicker("Color de Avatar", selection: $backgroundColor)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 1)
                    
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Personal Information Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Información Personal")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.brown)
                                    .frame(width: 25)
                                TextField("Nombre completo", text: $userName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Agricultural Data Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Datos Agrícolas")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.brown)
                                    .frame(width: 25)
                                TextField("Tipo de cultivo", text: $cropType)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "mountain.2.fill")
                                    .foregroundColor(.brown)
                                    .frame(width: 25)
                                TextField("Tipo de suelo", text: $soilType)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundColor(.brown)
                                    .frame(width: 25)
                                TextField("Tamaño del terreno (ha)", text: $landSize)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Preferences Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Preferencias")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Toggle(isOn: $notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.brown)
                                Text(notificationsEnabled ? "Notificaciones Activadas" : "Notificaciones Desactivadas")
                            }
                        }
                        .padding(.horizontal)
                        .tint(.brown)
                    }
                    
                    // Save Button
                    Button(action: {
                        saveProfile()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Guardar Cambios")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(10)
                        .shadow(color: .brown.opacity(0.3), radius: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle(languageManager.localizedString("edit_profile"))
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
    private func saveProfile() {
        // Save profile data to UserDefaults or your backend
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(selectedAvatar, forKey: "selectedAvatar")
        UserDefaults.standard.set(cropType, forKey: "cropType")
        UserDefaults.standard.set(soilType, forKey: "soilType")
        UserDefaults.standard.set(landSize, forKey: "landSize")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        
        // Show confirmation (you can add an alert here)
        print("Profile saved successfully")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
