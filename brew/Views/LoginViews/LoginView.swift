//
//  LoginView.swift
//  brew
//
//  Created by toño on 26/09/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @ObservedObject var authVM: AuthViewModel
    
    // Brew color palette - supports light and dark mode
    private let brewDarkBrown = Color(hex: "#403003")      // Dark brown
    private let brewMediumBrown = Color(hex: "#51391D")    // Medium brown
    private let brewOlive = Color(hex: "#737839")          // Olive green
    private let brewTan = Color(hex: "#A69072")            // Tan/beige
    private let brewCream = Color(hex: "#E3DBC7")          // Cream
    private let brewWhite = Color(hex: "#F5F4EF")          // Off-white

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Header with Logo
                    VStack(spacing: 16) {
                        // Custom leaf logo with brand colors
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [brewMediumBrown.opacity(0.1), brewMediumBrown.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [brewMediumBrown, brewDarkBrown],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(-15))
                        }
                        .padding(.top, 60)
                        
                        Text("Brew")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundColor(brewMediumBrown)
                        
                        Text("Gestiona tus cultivos inteligentemente")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 50)
                    
                    // MARK: - Login Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Correo Electrónico")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(brewMediumBrown.opacity(0.8))
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(brewTan)
                                    .frame(width: 20)
                                
                                TextField("tu@email.com", text: $email)
                                    .autocapitalization(.none)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(brewCream.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(brewMediumBrown.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(brewMediumBrown.opacity(0.8))
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(brewTan)
                                    .frame(width: 20)
                                
                                if showPassword {
                                    TextField("Tu contraseña", text: $password)
                                } else {
                                    SecureField("Tu contraseña", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(brewTan)
                                }
                            }
                            .padding()
                            .background(brewCream.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(brewMediumBrown.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("¿Olvidaste tu contraseña?") {
                                // Handle forgot password
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(brewOlive)
                        }
                        .padding(.top, -8)
                        
                        // Login Button
                        Button(action: {
                            authVM.login(email: email, password: password)
                        }) {
                            HStack(spacing: 12) {
                                Text("Iniciar Sesión")
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(brewWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [brewDarkBrown, brewMediumBrown],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: brewDarkBrown.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 10)
                        
                        // Error Message
                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                Text(error)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Register Link
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(brewTan.opacity(0.3))
                            
                            Text("o")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(brewTan.opacity(0.3))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        HStack(spacing: 4) {
                            Text("¿No tienes cuenta?")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            NavigationLink(destination: RegisterView(authVM: authVM)) {
                                Text("Regístrate ahora")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(brewOlive)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    LoginView(authVM: AuthViewModel())
}
