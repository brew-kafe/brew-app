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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Header with Logo/Icon
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.green.gradient)
                            .padding(.top, 60)
                        
                        Text("Brew")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                        
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
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("tu@email.com", text: $email)
                                    .autocapitalization(.none)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                if showPassword {
                                    TextField("Tu contraseña", text: $password)
                                } else {
                                    SecureField("Tu contraseña", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("¿Olvidaste tu contraseña?") {
                                // Handle forgot password
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                        }
                        .padding(.top, -8)
                        
                        // Login Button
                        Button(action: {
                            authVM.login(email: email, password: password)
                        }) {
                            HStack {
                                Text("Iniciar Sesión")
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.top, 10)
                        
                        // Error Message
                        if let error = authVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
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
                    VStack(spacing: 12) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("o")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        HStack(spacing: 4) {
                            Text("¿No tienes cuenta?")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            NavigationLink(destination: Text("RegisterView")) {
                                Text("Regístrate ahora")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.green)
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
