//
//  LoginView.swift
//  brew
//
//  Created by Humberto Canedo Cebreros on 08/09/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(spacing: 28) {
            
            // Logo
            VStack {
                Image("brew_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("Brew")
                    .font(.system(size: 64, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 81/255, green: 57/255, blue: 29/255))
            }
            .padding(.top, 50)
            .padding(.bottom, 30)
            // Username Field
            HStack {
                TextField("Usuario...", text: $username)
                    .autocapitalization(.none)
                    .padding()
                
                Image(systemName: "person")
                    .foregroundColor(.brown.opacity(0.7))
                    .padding(.trailing, 12)
            }
            .background(RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 94/255, green: 98/255, blue: 48/255), lineWidth: 1))
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            .padding(.horizontal)
            .frame(width: 300)

            // The password section has dummy numbers and actions because the Database is not up already, this will be to have the view while we develop the DB and connection with the API.
            // Password Field
            HStack {

                // Conditional field
                if showPassword {
                    TextField("Contraseña...", text: $password)
                        .padding()
                } else {
                    SecureField("Contraseña...", text: $password)
                        .padding()
                }

                // Eye toggle button on the right
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.brown.opacity(0.7))
                        .padding(.trailing, 12)
                }
            }
            .background(RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 94/255, green: 98/255, blue: 48/255), lineWidth: 1))
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            .padding(.horizontal)
            .frame(width: 300)
            .padding(.bottom,30)
            
            // Login Button
            Button(action: {
                print("Iniciar sesión tapped")
            }) {
                Text("Iniciar")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 94/255, green: 98/255, blue: 48/255)) // olive green
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .padding(.horizontal)
            .frame(width: 300)
            .padding(.bottom,35)

            
            // Forgot Password
            Button(action: {
                print("Forgot password tapped")
            }) {
                Text("¿Olvidaste tu contraseña?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 81/255, green: 57/255, blue: 29/255))
                    .underline()
            }
            
            // Create account
            Button(action: {
                print("Create account tapped")
            }) {
                Text("¿No tienes una cuenta?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 81/255, green: 57/255, blue: 29/255))
                    .underline()
            }
            
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
