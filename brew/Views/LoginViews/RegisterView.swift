//
//  RegisterView.swift
//  LoginRegisterApp
//
//  Created by toño on 26/09/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var authVM = AuthViewModel()

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role = "user"
    @State private var cooperativeID: String = ""   // text field, convert to Int
    @State private var showSuccess = false

    let roles = ["user", "superuser", "manager", "technician"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Picker("Role", selection: $role) {
                    ForEach(roles, id: \.self) { role in
                        Text(role.capitalized).tag(role)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Cooperative ID (optional)", text: $cooperativeID)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Button(action: {
                    let coopIDInt = Int(cooperativeID)
                    authVM.register(
                        name: name,
                        email: email,
                        password: password,
                        role: role,
                        cooperativeID: coopIDInt
                    )
                    showSuccess = true
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty || email.isEmpty || password.isEmpty)

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text("User registered successfully!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
