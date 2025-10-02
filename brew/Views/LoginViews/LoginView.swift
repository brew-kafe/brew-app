//
//  LoginView.swift
//  LoginRegisterApp
//
//  Created by toño on 26/09/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button("Login") {
                    authVM.login(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)

                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationDestination(isPresented: $authVM.isAuthenticated) {
                UserListView(userVM: UserViewModel())
            }
        }
    }
}
