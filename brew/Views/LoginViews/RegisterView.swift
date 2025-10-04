//
//  RegisterView.swift
//  brew
//
//  Created by toño on 26/09/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authVM: AuthViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var cooperativeID: String = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?
    
    // Brew brand colors
    private let brewBrown = Color(red: 81/255, green: 57/255, blue: 29/255)
    private let brewLightBrown = Color(red: 123/255, green: 97/255, blue: 64/255)
    private let brewAccent = Color(red: 163/255, green: 134/255, blue: 97/255)
    
    enum Field: Hashable {
        case name, email, password, confirmPassword, cooperativeID
    }
    
    private var passwordsMatch: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        passwordsMatch &&
        password.count >= 6
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                VStack(spacing: 16) {
                    // Custom leaf logo with person icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [brewBrown.opacity(0.1), brewBrown.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        ZStack {
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundColor(brewAccent.opacity(0.3))
                                .rotationEffect(.degrees(-15))
                                .offset(x: -5, y: -5)
                            
                            Image(systemName: "person.fill.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [brewBrown, brewLightBrown],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .padding(.top, 40)
                    
                    Text("Crear Cuenta")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(brewBrown)
                    
                    Text("Únete a Brew y comienza a gestionar tus cultivos")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
                
                // MARK: - Registration Form
                VStack(spacing: 20) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre Completo")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(brewBrown.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(brewAccent)
                                .frame(width: 20)
                            
                            TextField("Juan Pérez", text: $name)
                                .focused($focusedField, equals: .name)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .email
                                }
                        }
                        .padding()
                        .background(brewBrown.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .name ? brewBrown : brewBrown.opacity(0.1), lineWidth: focusedField == .name ? 2 : 1)
                        )
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Correo Electrónico")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(brewBrown.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(brewAccent)
                                .frame(width: 20)
                            
                            TextField("tu@email.com", text: $email)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        .padding()
                        .background(brewBrown.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .email ? brewBrown : brewBrown.opacity(0.1), lineWidth: focusedField == .email ? 2 : 1)
                        )
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contraseña")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(brewBrown.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(brewAccent)
                                .frame(width: 20)
                            
                            if showPassword {
                                TextField("Mínimo 6 caracteres", text: $password)
                                    .focused($focusedField, equals: .password)
                            } else {
                                SecureField("Mínimo 6 caracteres", text: $password)
                                    .focused($focusedField, equals: .password)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(brewAccent)
                            }
                        }
                        .padding()
                        .background(brewBrown.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .password ? brewBrown : brewBrown.opacity(0.1), lineWidth: focusedField == .password ? 2 : 1)
                        )
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }
                        
                        if !password.isEmpty && password.count < 6 {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("La contraseña debe tener al menos 6 caracteres")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirmar Contraseña")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(brewBrown.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(brewAccent)
                                .frame(width: 20)
                            
                            if showConfirmPassword {
                                TextField("Repite tu contraseña", text: $confirmPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                            } else {
                                SecureField("Repite tu contraseña", text: $confirmPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                            }
                            
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(brewAccent)
                            }
                            
                            if passwordsMatch {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(brewBrown)
                            }
                        }
                        .padding()
                        .background(brewBrown.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .confirmPassword ? brewBrown : brewBrown.opacity(0.1), lineWidth: focusedField == .confirmPassword ? 2 : 1)
                        )
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .cooperativeID
                        }
                        
                        if !confirmPassword.isEmpty && !passwordsMatch {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Las contraseñas no coinciden")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    // Cooperative ID Field (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ID de Cooperativa")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(brewBrown.opacity(0.8))
                            
                            Text("(Opcional)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(brewAccent)
                                .frame(width: 20)
                            
                            TextField("Ej: 12345", text: $cooperativeID)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .cooperativeID)
                        }
                        .padding()
                        .background(brewBrown.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .cooperativeID ? brewBrown : brewBrown.opacity(0.1), lineWidth: focusedField == .cooperativeID ? 2 : 1)
                        )
                    }
                    
                    // Register Button
                    Button(action: {
                        focusedField = nil
                        let coopIDInt = Int(cooperativeID)
                        authVM.register(
                            name: name,
                            email: email,
                            password: password,
                            role: "user",
                            cooperativeID: coopIDInt
                        )
                        if authVM.errorMessage == nil {
                            showSuccess = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text("Crear Cuenta")
                                .font(.system(size: 17, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isFormValid ? [brewBrown, brewLightBrown] : [Color.gray.opacity(0.5), Color.gray.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: isFormValid ? brewBrown.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isFormValid)
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
                
                // MARK: - Login Link
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(brewBrown.opacity(0.2))
                        
                        Text("o")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(brewBrown.opacity(0.2))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    
                    HStack(spacing: 4) {
                        Text("¿Ya tienes cuenta?")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Inicia sesión")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(brewBrown)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .alert("¡Cuenta Creada!", isPresented: $showSuccess) {
            Button("Continuar") {
                dismiss()
            }
        } message: {
            Text("Tu cuenta ha sido registrada exitosamente. Ahora puedes iniciar sesión.")
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(authVM: AuthViewModel())
    }
}
