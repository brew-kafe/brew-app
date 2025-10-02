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
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.green.gradient)
                            .padding(.top, 40)
                        
                        Text("Crear Cuenta")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.primary)
                        
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
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("Juan Pérez", text: $name)
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .email
                                    }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .name ? Color.green : Color.clear, lineWidth: 2)
                            )
                        }
                        
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
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .password
                                    }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .email ? Color.green : Color.clear, lineWidth: 2)
                            )
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
                                    TextField("Mínimo 6 caracteres", text: $password)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Mínimo 6 caracteres", text: $password)
                                        .focused($focusedField, equals: .password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .password ? Color.green : Color.clear, lineWidth: 2)
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
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
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
                                        .foregroundColor(.secondary)
                                }
                                
                                if passwordsMatch {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .confirmPassword ? Color.green : Color.clear, lineWidth: 2)
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
                                    .foregroundColor(.secondary)
                                
                                Text("(Opcional)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                            
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                TextField("Ej: 12345", text: $cooperativeID)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .cooperativeID)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .cooperativeID ? Color.green : Color.clear, lineWidth: 2)
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
                            HStack {
                                Text("Crear Cuenta")
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: isFormValid ? [.green, .green.opacity(0.8)] : [.gray, .gray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
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
                    
                    // MARK: - Login Link
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
                            Text("¿Ya tienes cuenta?")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Inicia sesión")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color(.systemBackground))
            .alert("¡Cuenta Creada!", isPresented: $showSuccess) {
                Button("Continuar") {
                    dismiss()
                }
            } message: {
                Text("Tu cuenta ha sido registrada exitosamente. Ahora puedes iniciar sesión.")
            }
        }
    }
}

#Preview {
    RegisterView(authVM: AuthViewModel())
}
